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
  
  private let session = ARSession()
  private let sessionConfig = ARWorldTrackingConfiguration()
  public private(set) weak var sceneNode: SCNNode?
  public private(set) weak var basePlane: SCNNode?
  private var currentCameraTrackingState: ARCamera.TrackingState? = nil
  private var placemarks = Set<PlacemarkNode>()
  
  var savedLocations: [SavedLocation] {
    return self.savedLocationsFetchedResultsController?.fetchedObjects ?? []
  }
  
  private lazy var savedLocationsFetchedResultsController: NSFetchedResultsController<SavedLocation>? = {
    let controller = SavedLocation.newFetchedResultsController()
    controller.delegate = self
    try? controller.performFetch()
    return controller
  }()
  
  var scneViewCenter: CGPoint {
    return self.sceneView.bounds.mid
  }
  
  var currentScenePosition: SCNVector3? {
    
    guard let pointOfView = self.sceneView.pointOfView else {
      return nil
    }
    
    return self.sceneView.scene.rootNode.convertPosition(pointOfView.position, to: self.sceneNode)
  }
  
  var currentLocation: CLLocation? = nil {
    didSet {
      if self.isViewLoaded {
        self.updatePlacemarks(updatePosition: true)
      }
    }
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.sceneView.setUp(delegate: self, session: self.session)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    UIApplication.shared.isIdleTimerDisabled = true
    self.restartPlaneDetection()
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.restartPlaneDetection), name: .UIApplicationDidBecomeActive, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.pauseScene), name: .UIApplicationWillResignActive, object: nil)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    self.pauseScene()
    NotificationCenter.default.removeObserver(self)
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
  
  private func add(placemark: PlacemarkNode) {
    self.placemarks.insert(placemark)
    placemark.loadModel { [weak self] in
      self?.update(placemark: placemark, animated: true, updatePosition: true)
      self?.sceneNode?.addChildNode(placemark)
    }
  }
  
  internal func updatePlacemarks(updatePosition: Bool = true) {
    for placemark in self.placemarks {
      self.update(placemark: placemark, animated: true, updatePosition: updatePosition)
    }
  }
  
  // MARK: - KAK TO REFACTOR
  
  func update(placemark: PlacemarkNode, initialSetup: Bool = false, animated: Bool = false, duration: TimeInterval = 0.1, updatePosition: Bool = true) {
    Log.log("Updating placemark \(placemark.savedLocation.name ?? "nil name") at location \(placemark.savedLocation.location.coordinate)")
    
    // Saved location updates
    let savedLocation = placemark.savedLocation
    
    // Update name
    if placemark.primaryName != savedLocation.name {
      placemark.primaryName = savedLocation.name
    }
    
    // Distance and unit text
    let distanceAndUnitText = self.getDistanceAndUnitText(savedLocation: savedLocation)
    
    // Update distance text
    if placemark.distanceText != distanceAndUnitText.distanceText {
      placemark.distanceText = distanceAndUnitText.distanceText
    }
    
    // Update unit text
    if placemark.unitText != distanceAndUnitText.unitText {
      placemark.unitText = distanceAndUnitText.unitText
    }
    
    // Update the color
    if let color = savedLocation.color {
      placemark.beamColor = color.color
    }
    
    // Scene location updates
    guard updatePosition, let currentPosition = self.currentScenePosition, let currentLocation = self.currentLocation else {
      return
    }
    
    SCNTransaction.begin()
    
    if animated {
      SCNTransaction.animationDuration = duration
    } else {
      SCNTransaction.animationDuration = 0
    }
    
    // Position is set to a position coordinated via the current position
    let adjustedDistance: CLLocationDistance
    let locationTranslation = currentLocation.translation(toLocation: savedLocation.location)
    let distance = savedLocation.location.distance(from: currentLocation)
    
    if distance > Double.shortDistanceCutoff {

      //If the item is too far away, bring it closer and scale it down
      let scale = 100 / Float(distance)
      let yOffset: Float = -50
      adjustedDistance = distance * Double(scale)

      let adjustedTranslation = SCNVector3(
        x: Float(locationTranslation.longitudeTranslation) * scale,
        y: Float(locationTranslation.altitudeTranslation) * scale,
        z: Float(locationTranslation.latitudeTranslation) * scale)

      let position = SCNVector3(
        x: currentPosition.x + adjustedTranslation.x,
        y: currentPosition.y + adjustedTranslation.y + yOffset,
        z: currentPosition.z - adjustedTranslation.z)

      placemark.position = position
      placemark.scale = SCNVector3(x: scale, y: scale, z: scale)

    } else {

      let yOffset: Float = -11
      adjustedDistance = distance
      let position = SCNVector3(
        x: currentPosition.x + Float(locationTranslation.longitudeTranslation),
        y: currentPosition.y + Float(locationTranslation.altitudeTranslation) + yOffset,
        z: currentPosition.z - Float(locationTranslation.latitudeTranslation))

      placemark.position = position
      placemark.scale = SCNVector3(x: 1, y: 1, z: 1)
    }

    if let placemark = placemark as? BillboardPlacemarkNode {
      //The scale of a node with a billboard constraint applied is ignored
      //The annotation subnode itself, as a subnode, has the scale applied to it
      let appliedScale = placemark.scale
      placemark.scale = SCNVector3(x: 1, y: 1, z: 1)

      var scale: Float
      if placemark.scaleRelativeToDistance {
        scale = appliedScale.y
        placemark.scalableNode?.scale = appliedScale
      } else {
        
        //Scale it to be an appropriate size so that it can be seen
        scale = Float(adjustedDistance) * 0.181

        if distance > 3000 {
          scale = scale * 0.75
        }
        placemark.scalableNode?.scale = SCNVector3(x: scale, y: scale, z: scale)
      }

      placemark.pivot = SCNMatrix4MakeTranslation(0, -1.1 * scale, 0)
    }
    
    SCNTransaction.commit()
  }
  
  private func getDistanceAndUnitText(savedLocation: SavedLocation) -> (distanceText: String?, unitText: String?) {
    let distanceText: String?
    let unitText: String?
    if let currentLocation = self.currentLocation {
      let distance = currentLocation.distance(from: savedLocation.location)
      distanceText = distance.getDistanceValue(nearUnitType: Defaults.shared.nearUnitType, farUnitType: Defaults.shared.farUnitType, asShortValue: true)
      unitText = distance.getUnitTypeString(nearUnitType: Defaults.shared.nearUnitType, farUnitType: Defaults.shared.farUnitType, asShortString: true)
    } else {
      distanceText = nil
      unitText = nil
    }
    return (distanceText, unitText)
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
    let placemark = BillboardPlacemarkNode(savedLocation: savedLocation)
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
