//
//  ARViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit
import ARKit
import CoreLocation
import CoreData

protocol ARViewControllerDelegate : class {
  func userDidTap(placemark: Placemark)
}

class ARViewController : UIViewController {
  
  // MARK: - Properties
  
  @IBOutlet weak var sceneView: ARSCNView!
  
  weak var delegate: ARViewControllerDelegate? = nil
  weak var trackingStateDelegate: ARStateDelegate? = nil
  private let session = ARSession()
  private let sessionConfig = ARWorldTrackingConfiguration()
  public private(set) var sceneNode: SCNNode?
  public private(set) var basePlane: SCNNode?
  public private(set) var axisNode: AxisNode?
  
  // MARK: - Defaults
  
  var appMode: AppMode? = nil {
    didSet {
      
      guard let appMode = self.appMode else {
        self.appMode = self.defaults.appMode
        return
      }
      
      // Check if the app mode has changed
      guard appMode != oldValue else {
        return
      }
      
      // Updates based on appMode
      self.placemarksFetchedResultsController = Placemark.newFetchedResultsController(placemarkType: appMode)
      if self.isViewLoaded {
        self.removeAllNodesFromScene()
        self.updatePlacemarks()
      }
    }
  }
  
  var defaults: Defaults {
    return self.defaultsFetchedResultsController.fetchedObjects?.first ?? Defaults.shared
  }
  
  private lazy var defaultsFetchedResultsController: NSFetchedResultsController<Defaults> = {
    let controller = Defaults.newFetchedResultsController()
    controller.delegate = self
    try? controller.performFetch()
    return controller
  }()
  
  // MARK: - Placemark Data Source
  
  internal var placemarkNodeContainers = Set<PlacemarkNodeContainer>()
  
  var placemarks: [Placemark] {
    
    guard let placemarksFetchedResultsController = self.placemarksFetchedResultsController else {
      self.appMode = self.defaults.appMode
      return []
    }
    
    return placemarksFetchedResultsController.fetchedObjects ?? []
  }
  
  private var placemarksFetchedResultsController: NSFetchedResultsController<Placemark>? = nil {
    didSet {
      self.placemarksFetchedResultsController?.delegate = self
      try? self.placemarksFetchedResultsController?.performFetch()
    }
  }
  
  // MARK: - AR Scene Properties
  
  private var currentCameraTrackingState: ARCamera.TrackingState? = nil {
    didSet {
      
      guard let currentCameraTrackingState = self.currentCameraTrackingState else {
        self.state = .configuring
        return
      }
      
      switch currentCameraTrackingState {
      case .limited(.insufficientFeatures):
        self.state = .limited(.insufficientFeatures)
      case .limited(.excessiveMotion):
        self.state = .limited(.excessiveMotion)
      case .limited(.initializing):
        self.state = .limited(.initializing)
//      case .limited(.relocalizing):
//        self.state = .limited(.relocalizing)
      case .normal:
        self.state = .normal
      case .notAvailable:
        self.state = .notAvailable
      }
    }
  }
  
  var state: ARState? = nil {
    didSet {
      
      // Check if running on simulator
      if UIDevice.current.isSimulator {
        self.state = .normal
        self.trackingStateDelegate?.arStateDidUpdate(.normal)
        return
      }
      
      if let state = self.state {
        self.trackingStateDelegate?.arStateDidUpdate(state)
      }
    }
  }
  
  var sceneViewCenter: CGPoint {
    return self.sceneView.bounds.mid
  }
  
  var currentScenePosition: SCNVector3? {
    if let pointOfView = self.sceneView.pointOfView {
      return self.sceneView.scene.rootNode.convertPosition(pointOfView.position, to: self.sceneNode)
    }
    return nil
  }
  
  // MARK: - Location Properties
  
  var currentLocation: CLLocation? {
    return LocationManager.shared.currentLocation
  }
  
  var currentHeading: CLHeading? {
    return LocationManager.shared.currentHeading
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup the scene
    self.sceneView.setUp(delegate: self, session: self.session)
    
    // Listen for gestures
    self.startListeningForGestures()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Set idle timer flag
    UIApplication.shared.isIdleTimerDisabled = true
    
    // Start / restart plane detection
    self.restartPlaneDetection()
    
    // Check camera tracking state
    self.trackingStateDelegate?.arStateDidUpdate(self.state ?? .configuring)
    
    // Notifications
    NotificationCenter.default.addObserver(self, selector: #selector(self.restartPlaneDetection), name: .UIApplicationDidBecomeActive, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.pauseScene), name: .UIApplicationWillResignActive, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveUpdatedLocationNotification(_:)), name: .locationManagerDidUpdateCurrentLocation, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveUpdatedHeadingNotification(_:)), name: .locationManagerDidUpdateCurrentHeading, object: nil)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    // Reset idle timer flat
    UIApplication.shared.isIdleTimerDisabled = false
    
    // Pause the AR scene
    self.pauseScene()
    
    // Check camera tracking state
    self.trackingStateDelegate?.arStateDidUpdate(self.state ?? .configuring)
    
    // Remove self from notifications
    NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
    NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
    NotificationCenter.default.removeObserver(self, name: .locationManagerDidUpdateCurrentLocation, object: nil)
    NotificationCenter.default.removeObserver(self, name: .locationManagerDidUpdateCurrentHeading, object: nil)
  }
  
  // MARK: - Notifications
  
  @objc func didReceiveUpdatedLocationNotification(_ notification: Notification) {
    self.updatePlacemarkNodes(updatePosition: true)
  }
  
  @objc func didReceiveUpdatedHeadingNotification(_ notification: Notification) {}
  
  // MARK: - Scene
  
  @objc func pauseScene() {
    
    guard !UIDevice.current.isSimulator else {
      self.state = .normal
      return
    }
    
    self.session.pause()
  }
  
  @objc func restartPlaneDetection() {
    
    guard !UIDevice.current.isSimulator else {
      self.state = .normal
      return
    }
    
    // Remove all nodes
    self.removeAllNodesFromScene()
    
    // Configure session
    self.sessionConfig.isLightEstimationEnabled = true
    self.sessionConfig.worldAlignment = .gravityAndHeading
    self.session.run(self.sessionConfig, options: [.resetTracking, .removeExistingAnchors])
  }
  
  func removeAllNodesFromScene() {
    
    guard self.isViewLoaded else {
      return
    }
    
    self.sceneNode?.removeFromParentNode()
    self.sceneNode = nil
    self.basePlane?.removeFromParentNode()
    self.basePlane = nil
    for placemarkNodeContainer in self.placemarkNodeContainers {
      placemarkNodeContainer.placemarkNode?.removeFromParentNode()
      placemarkNodeContainer.placemarkNode = nil
    }
    self.placemarkNodeContainers.removeAll()
    self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
      node.removeFromParentNode()
    }
  }
  
  // MARK: - Placemark Node Containers
  
  private func add(placemarkNodeContainer: PlacemarkNodeContainer) {
    self.placemarkNodeContainers.insert(placemarkNodeContainer)
    self.update(placemarkNodeContainer: placemarkNodeContainer, animated: true, updatePosition: true)
  }
  
  internal func updatePlacemarkNodes(updatePosition: Bool = true) {
    for placemarkNodeContainer in self.placemarkNodeContainers {
      self.update(placemarkNodeContainer: placemarkNodeContainer, animated: true, updatePosition: updatePosition)
    }
  }
  
  // MARK: - Updating placemarks
  
  internal func update(placemarkNodeContainer: PlacemarkNodeContainer, animated: Bool = false, updatePosition: Bool = true) {
    Log.log("Updating placemark \(placemarkNodeContainer.placemark.name ?? "nil name") at location \(placemarkNodeContainer.placemark.location.coordinate)")
    
    // Refresh saved location properties
    placemarkNodeContainer.refreshContent()
    
    // Scene location updates
    if updatePosition, let currentScenePosition = self.currentScenePosition, let currentLocation = self.currentLocation {
      
      // Distance to the saved location object
      let distance = placemarkNodeContainer.placemark.location.distance(from: currentLocation)
      let distanceType = ARDistanceType(distance: distance)
      
      // Update the active placemark node
      let dispatchGroup = DispatchGroup()
      let duration: TimeInterval = 0.5
      
      switch distanceType {
      case .close:
        if !placemarkNodeContainer.isDefaultPlacemarkNode {
          dispatchGroup.enter()
          let defaultPlacemarkNode = PlacemarkNode()
          defaultPlacemarkNode.loadModel { [weak self] in
            placemarkNodeContainer.placemarkNode?.removeFromParentNode()
            placemarkNodeContainer.placemarkNode = defaultPlacemarkNode
            
            placemarkNodeContainer.refreshContent()
            self?.sceneNode?.addChildNode(defaultPlacemarkNode)
            dispatchGroup.leave()
          }
        }
      case .medium:
        if !placemarkNodeContainer.isTextFlagPlacemarkNode {
          dispatchGroup.enter()
          let textFlagPlacemarkNode = TextFlagPlacemarkNode()
          textFlagPlacemarkNode.loadModel { [weak self] in
            placemarkNodeContainer.placemarkNode?.removeFromParentNode()
            placemarkNodeContainer.placemarkNode = textFlagPlacemarkNode
            textFlagPlacemarkNode.beamTransparency = 0.25
            
            placemarkNodeContainer.refreshContent()
            self?.sceneNode?.addChildNode(textFlagPlacemarkNode)
            dispatchGroup.leave()
          }
        }
      case .far:
        placemarkNodeContainer.placemarkNode?.removeFromParentNode()
        placemarkNodeContainer.placemarkNode = nil
      }
      
      // Wait until the active placemark node has been set
      dispatchGroup.notify(queue: .main) { [weak placemarkNodeContainer] in
        
        guard let placemarkNodeContainer = placemarkNodeContainer, let placemarkNode = placemarkNodeContainer.placemarkNode else {
          return
        }
        
        // Translated location
        let locationTranslation = currentLocation.translation(toLocation: placemarkNodeContainer.placemark.location)
        
        // Update the placemark based on the distance
        switch distanceType {
        case .close:
          
          // Scale the node according to distance where at a zero distance the node will have a height of 50m
          let desiredNodeHeight: Float = 50 + Float(distance)
          let additionalScaleByDistance: Float = Float(distance) * 0.025
          let scale = (desiredNodeHeight / placemarkNode.boundingBox.max.y) + additionalScaleByDistance
          placemarkNode.scalableNode?.scale = SCNVector3(x: scale, y: scale, z: scale)
          
          // Update the position
          let xPos = currentScenePosition.x + Float(locationTranslation.longitudeTranslation)
          let yPos = currentScenePosition.y + Float(locationTranslation.altitudeTranslation)
          let zPos = currentScenePosition.z - Float(locationTranslation.latitudeTranslation)
          let position = SCNVector3(
            x: xPos,
            y: abs(yPos) > 200 ? -(placemarkNode.scalableNode?.boundingBox.max.y ?? 0) / 2 : yPos,
            z: zPos)
          let moveAction = SCNAction.move(to: position, duration: animated ? duration : 0)
          placemarkNode.runAction(moveAction)
          
        case .medium:
          let translationScale = 100 / distance
          let xPos = currentScenePosition.x + Float(locationTranslation.longitudeTranslation) * Float(translationScale)
          _ = currentScenePosition.y + Float(locationTranslation.altitudeTranslation) * Float(translationScale)
          let zPos = currentScenePosition.z - Float(locationTranslation.latitudeTranslation) * Float(translationScale)
          let position = SCNVector3(
            x: xPos,
            y: -placemarkNode.boundingBox.max.y / 4,
            z: zPos)
          let moveAction = SCNAction.move(to: position, duration: animated ? duration : 0)
          placemarkNode.runAction(moveAction)
          
          // Scale the node
          let scale = Float(distance * translationScale) * 0.2
          placemarkNode.scalableNode?.scale = SCNVector3(x: scale, y: scale, z: scale)
          
        case .far: break
        }
      }
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
        self.configureAxisNode()
        
        // Base plane
        let basePlane = Plane(width: 3000, length: 3000)
        basePlane.position = SCNVector3(x: 0, y: -5, z: 0)
        self.basePlane = basePlane
        self.sceneNode?.addChildNode(basePlane)
        
        // Update placemarks
        self.updatePlacemarks()
        self.updatePlacemarkNodes(updatePosition: true)
        
      default: break
      }
    }
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    Log.extendedLog("Session was interrupted")
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    Log.extendedLog("Session interruption ended")
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    Log.extendedLog("Session did fail with error: \(error)")
    
    // Update the AR state
    self.state = .error(error.localizedDescription)
  }
  
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    self.currentCameraTrackingState = camera.trackingState
    switch camera.trackingState {
    case .limited(.insufficientFeatures):
      Log.extendedLog("Camera did change tracking state: limited, insufficient features")
    case .limited(.excessiveMotion):
      Log.extendedLog("Camera did change tracking state: limited, excessive motion")
    case .limited(.initializing):
      Log.extendedLog("Camera did change tracking state: limited, initializing")
//    case .limited(.relocalizing):
//      Log.extendedLog("Camera did change tracking state: limited, relocalizing")
    case .normal:
      Log.extendedLog("Camera did change tracking state: normal")
    case .notAvailable:
      Log.extendedLog("Camera did change tracking state: not available")
    }
  }
}

// MARK: - NSFetchedResultsControllerDelegate

extension ARViewController : NSFetchedResultsControllerDelegate {
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {}
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
    guard controller == self.placemarksFetchedResultsController else {
      return
    }
    
    switch type {
    case .insert:
      if let placemark = anObject as? Placemark {
        self.add(placemark: placemark)
      }
      
    case .delete:
      if let placemark = anObject as? Placemark {
        self.remove(placemark: placemark)
      }
      
    case .update, .move:
      if let placemark = anObject as? Placemark {
        self.update(placemark: placemark)
      }
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    if controller == self.defaultsFetchedResultsController {
      self.configureAxisNode()
      self.appMode = self.defaults.appMode
    }
  }
  
  // MARK: - Axis Node
  
  func configureAxisNode() {
    
    // Check if should remove the show axis
    guard self.defaults.showAxis else {
      self.axisNode?.removeFromParentNode()
      self.axisNode = nil
      return
    }
    
    // Check if axis node has already been created
    guard self.axisNode == nil else {
      return
    }
    
    // Create the axis node
    let axisNode = AxisNode()
    self.axisNode = axisNode
    if let pointOfView = self.sceneView.pointOfView {
      axisNode.position = pointOfView.position
    }
    self.sceneNode?.addChildNode(axisNode)
  }
  
  // MARK: - Placemarks
  
  func updatePlacemarks() {
    
    guard self.isViewLoaded else {
      return
    }
    
    for placemark in self.placemarks {
      self.update(placemark: placemark)
    }
  }
  
  private func add(placemark: Placemark) {
    
    // Add placemark
    let placemarkNodeContainer = PlacemarkNodeContainer(placemark: placemark)
    self.add(placemarkNodeContainer: placemarkNodeContainer)
  }
  
  private func update(placemark: Placemark) {
    
    guard let placemarkNodeContainer = self.placemarkNodeContainers.first(where: { $0.placemark == placemark }) else {
      self.add(placemark: placemark)
      return
    }
    
    self.update(placemarkNodeContainer: placemarkNodeContainer)
  }
  
  private func remove(placemark: Placemark) {
    if let placemarkNodeContainer = self.placemarkNodeContainers.first(where: { $0.placemark == placemark }) {
      Log.log("Removing \(placemark.name ?? "nil name") at location \(placemark.location.coordinate)")
      self.placemarkNodeContainers.remove(placemarkNodeContainer)
      placemarkNodeContainer.placemarkNode?.removeFromParentNode()
    }
  }
}
