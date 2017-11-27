//
//  ARViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit
import ARKit
import CoreLocation
import CoreData

class ARViewController : UIViewController {
  
  // MARK: - Properties
  
  @IBOutlet weak var sceneView: ARSCNView!
  
  weak var trackingStateDelegate: ARStateDelegate? = nil
  private let session = ARSession()
  private let sessionConfig = ARWorldTrackingConfiguration()
  public private(set) weak var sceneNode: SCNNode?
  public private(set) weak var basePlane: SCNNode?
  private var placemarks = Set<SavedLocationNode>()
  
  private var currentCameraTrackingState: ARCamera.TrackingState? = nil {
    didSet {
      self.trackingStateDelegate?.arStateDidUpdate(self.state)
    }
  }
  
  var state: ARState {
    guard let currentCameraTrackingState = self.currentCameraTrackingState else {
      return .configuring
    }
    
    switch currentCameraTrackingState {
    case .limited(.insufficientFeatures):
      return .limited(.insufficientFeatures)
    case .limited(.excessiveMotion):
      return .limited(.excessiveMotion)
    case .limited(.initializing):
      return .limited(.initializing)
    case .normal:
      return .normal
    case .notAvailable:
      return .notAvailable
    }
  }
  
  var savedLocations: [SavedLocation] {
    return self.savedLocationsFetchedResultsController?.fetchedObjects ?? []
  }
  
  private lazy var savedLocationsFetchedResultsController: NSFetchedResultsController<SavedLocation>? = {
    let controller = SavedLocation.newFetchedResultsController()
    controller.delegate = self
    try? controller.performFetch()
    return controller
  }()
  
  var sceneViewCenter: CGPoint {
    return self.sceneView.bounds.mid
  }
  
  var currentScenePosition: SCNVector3? {
    if let pointOfView = self.sceneView.pointOfView {
      return self.sceneView.scene.rootNode.convertPosition(pointOfView.position, to: self.sceneNode)
    }
    return nil
  }
  
  var currentLocation: CLLocation? {
    return LocationManager.shared.currentLocation
  }
  
  var currentHeading: CLHeading? {
    return LocationManager.shared.currentHeading
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.sceneView.setUp(delegate: self, session: self.session)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Set idle timer flag
    UIApplication.shared.isIdleTimerDisabled = true
    
    // Start / restart plane detection
    self.restartPlaneDetection()
    
    // Check camera tracking state
    self.trackingStateDelegate?.arStateDidUpdate(self.state)
    
    // Notifications
    NotificationCenter.default.addObserver(self, selector: #selector(self.restartPlaneDetection), name: .UIApplicationDidBecomeActive, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.pauseScene), name: .UIApplicationWillResignActive, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveUpdatedLocationNotification(_:)), name: .locationManagerDidUpdateCurrentLocation, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveUpdatedHeadingNotification(_:)), name: .locationManagerDidUpdateCurrentHeading, object: nil)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    // Reset idle timer flat
    UIApplication.shared.isIdleTimerDisabled = true
    
    // Pause the AR scene
    self.pauseScene()
    
    // Check camera tracking state
    self.trackingStateDelegate?.arStateDidUpdate(self.state)
    
    // Remove self from notifications
    NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
    NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
    NotificationCenter.default.removeObserver(self, name: .locationManagerDidUpdateCurrentLocation, object: nil)
    NotificationCenter.default.removeObserver(self, name: .locationManagerDidUpdateCurrentHeading, object: nil)
  }
  
  // MARK: - Notifications
  
  @objc func didReceiveUpdatedLocationNotification(_ notification: Notification) {
    self.updatePlacemarks(updatePosition: true)
  }
  
  @objc func didReceiveUpdatedHeadingNotification(_ notification: Notification) {
    
  }
  
  // MARK: - Scene
  
  @objc func pauseScene() {
    self.session.pause()
  }
  
  @objc func restartPlaneDetection() {
    
    // Remove all nodes
    self.sceneNode = nil
    self.basePlane = nil
    self.placemarks.removeAll()
    self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
      node.removeFromParentNode()
    }
    
    // Configure session
    self.sessionConfig.planeDetection = .horizontal
    self.sessionConfig.isLightEstimationEnabled = true
    self.sessionConfig.worldAlignment = .gravityAndHeading
    self.session.run(self.sessionConfig, options: [.resetTracking, .removeExistingAnchors])
  }
  
  // MARK: - Placemarks
  
  private func add(placemark: SavedLocationNode) {
    self.placemarks.insert(placemark)
    self.update(placemark: placemark, animated: true, updatePosition: true) { [weak self] in
      self?.sceneNode?.addChildNode(placemark)
    }
  }
  
  internal func updatePlacemarks(updatePosition: Bool = true) {
    for placemark in self.placemarks {
      self.update(placemark: placemark, animated: true, updatePosition: updatePosition)
    }
  }
  
  // MARK: - KAK TO REFACTOR
  
  func update(placemark: SavedLocationNode, initialSetup: Bool = false, animated: Bool = false, duration: TimeInterval = 0.1, updatePosition: Bool = true, completion: (() -> Void)? = nil) {
    Log.log("Updating placemark \(placemark.savedLocation.name ?? "nil name") at location \(placemark.savedLocation.location.coordinate)")
    
    // Refresh saved location properties
    placemark.refreshContent()
    
    // Scene location updates
    if updatePosition, let currentScenePosition = self.currentScenePosition, let currentLocation = self.currentLocation {
      placemark.update(currentScenePosition: currentScenePosition, currentLocation: currentLocation, animated: animated, duration: duration, completion: completion)
    }
  }
}

// MARK: - ARSCNViewDelegate

extension ARViewController : ARSCNViewDelegate {
  
  func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
    
    // Set the root scene node if the camera tracking state is normal
    if self.sceneNode == nil, let cameraTrackingState = self.currentCameraTrackingState {
      switch cameraTrackingState {
      case .normal:
        let sceneNode = SCNNode()
        self.sceneNode = sceneNode
        scene.rootNode.addChildNode(sceneNode)
        
        // Axes node
        let axesNode = AxesNode()
        self.sceneNode?.addChildNode(axesNode)
        
        // Base plane
        let basePlane = Plane(width: 3000, length: 3000)
        basePlane.position = SCNVector3(x: 0, y: -5, z: 0)
        self.basePlane = basePlane
        self.sceneNode?.addChildNode(basePlane)
        
        // Update placemarks
        self.updateSavedLocations()
        self.updatePlacemarks(updatePosition: true)
        
      default: break
      }
    }
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    Log.extendedLog("session was interrupted")
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    Log.extendedLog("session interruption ended")
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    Log.extendedLog("session did fail with error: \(error)")
  }
  
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    self.currentCameraTrackingState = camera.trackingState
    switch camera.trackingState {
    case .limited(.insufficientFeatures):
      Log.extendedLog("camera did change tracking state: limited, insufficient features")
    case .limited(.excessiveMotion):
      Log.extendedLog("camera did change tracking state: limited, excessive motion")
    case .limited(.initializing):
      Log.extendedLog("camera did change tracking state: limited, initializing")
    case .normal:
      Log.extendedLog("camera did change tracking state: normal")
    case .notAvailable:
      Log.extendedLog("camera did change tracking state: not available")
    }
  }
}

// MARK: - NSFetchedResultsControllerDelegate

extension ARViewController : NSFetchedResultsControllerDelegate {
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {}
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      if let savedLocation = anObject as? SavedLocation {
        self.add(savedLocation: savedLocation)
      }
      
    case .delete:
      if let savedLocation = anObject as? SavedLocation {
        self.remove(savedLocation: savedLocation)
      }
      
    case .update, .move:
      if let savedLocation = anObject as? SavedLocation {
        self.update(savedLocation: savedLocation)
      }
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {}
  
  // MARK: - Saved Locations
  
  func updateSavedLocations() {
    for savedLocation in self.savedLocations {
      self.update(savedLocation: savedLocation)
    }
  }
  
  private func add(savedLocation: SavedLocation) {
    
    // Add placemark
    let placemark = SavedLocationNode(savedLocation: savedLocation)
    self.add(placemark: placemark)
  }
  
  private func update(savedLocation: SavedLocation) {
    
    guard let placemark = self.placemarks.first(where: { $0.savedLocation == savedLocation }) else {
      self.add(savedLocation: savedLocation)
      return
    }
    
    self.update(placemark: placemark)
  }
  
  private func remove(savedLocation: SavedLocation) {
    if let placemark = self.placemarks.first(where: { $0.savedLocation == savedLocation }) {
      Log.log("Removing \(savedLocation.name ?? "nil name") at location \(savedLocation.location.coordinate)")
      self.placemarks.remove(placemark)
      placemark.removeFromParentNode()
    }
  }
}
