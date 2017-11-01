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

class ARViewController : UIViewController {
  
  // MARK: - Properties
  
  @IBOutlet weak var sceneView: ARSCNView!
  
  private let session = ARSession()
  private let sessionConfig = ARWorldTrackingConfiguration()
  public private(set) weak var sceneNode: SCNNode?
  public private(set) weak var basePlane: SCNNode?
  private var currentCameraTrackingState: ARCamera.TrackingState? = nil
  private var placemarks = Set<PlacemarkNode>()
  
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
      if self.isViewLoaded && oldValue == nil {
        self.updatePositionAndScaleOfPlacemarks()
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
    self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
      node.removeFromParentNode()
    }
    
    // Configure session
    self.sessionConfig.planeDetection = .horizontal
    self.sessionConfig.isLightEstimationEnabled = true
    self.sessionConfig.worldAlignment = .gravityAndHeading
    self.session.run(self.sessionConfig, options: [.resetTracking, .removeExistingAnchors])
  }
  
  // MARK: - KAK TO REFACTOR
  
  func add(savedLocation: SavedLocation) {
    let location = savedLocation.location
    let distanceText: String
    if let currentLocation = self.currentLocation {
      distanceText = "\(currentLocation.distance(from: location).oneDecimal)"
    } else {
      distanceText = "NA"
    }
    let unitText = Defaults.shared.nearUnitType.nearName
    let placemark = BillboardPlacemarkNode(location: location, primaryName: savedLocation.name, distanceText: distanceText, unitText: unitText, beamColor: .cyan, beamTransparency: 1)
    self.add(placemark: placemark)
  }
  
  func remove(savedLocation: SavedLocation) {
    self.sceneView.scene.rootNode.enumerateChildNodes { (child, _) in
      if let placemark = child as? PlacemarkNode, placemark.location == savedLocation.location {
        placemark.removeFromParentNode()
      }
    }
  }
  
  private func add(placemark: PlacemarkNode) {
    placemark.loadModel { [weak self] in
      self?.updatePositionAndScale(placemark: placemark, animated: true)
      self?.placemarks.insert(placemark)
      self?.sceneNode?.addChildNode(placemark)
    }
  }
  
  private func updatePositionAndScaleOfPlacemarks() {
    for placemark in self.placemarks {
      self.updatePositionAndScale(placemark: placemark, animated: true)
    }
  }
  
  ///Gives the best estimate of the location of a node
  private func getLocation(placemark: PlacemarkNode) -> CLLocation? {
    return placemark.location
    //    if locationNode.locationConfirmed || locationEstimateMethod == .coreLocationDataOnly {
    //      return locationNode.location!
    //    }
    //
    //    if let bestLocationEstimate = bestLocationEstimate(),
    //      locationNode.location == nil ||
    //        bestLocationEstimate.location.horizontalAccuracy < locationNode.location!.horizontalAccuracy {
    //      let translatedLocation = bestLocationEstimate.translatedLocation(to: locationNode.position)
    //
    //      return translatedLocation
    //    } else {
    //      return locationNode.location!
    //    }
  }
  
  func updatePositionAndScale(placemark: PlacemarkNode, initialSetup: Bool = false, animated: Bool = false, duration: TimeInterval = 0.1) {
    
    guard let currentPosition = self.currentScenePosition, let currentLocation = self.currentLocation, let locationNodeLocation = self.getLocation(placemark: placemark) else {
      return
    }
    
    SCNTransaction.begin()
    
    if animated {
      SCNTransaction.animationDuration = duration
    } else {
      SCNTransaction.animationDuration = 0
    }
    
    //Position is set to a position coordinated via the current position
    let locationTranslation = currentLocation.translation(toLocation: locationNodeLocation)
    
    let adjustedDistance: CLLocationDistance
    
    let distance = locationNodeLocation.distance(from: currentLocation)
    
    if distance > 100 || placemark.continuallyAdjustNodePositionWhenWithinRange || initialSetup {
      if distance > 100 {
        //If the item is too far away, bring it closer and scale it down
        let scale = 100 / Float(distance)
        let yOffset: Float = -30
        
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
        
        let yOffset: Float = -8
        adjustedDistance = distance
        let position = SCNVector3(
          x: currentPosition.x + Float(locationTranslation.longitudeTranslation),
          y: currentPosition.y + Float(locationTranslation.altitudeTranslation) + yOffset,
          z: currentPosition.z - Float(locationTranslation.latitudeTranslation))
        
        placemark.position = position
        placemark.scale = SCNVector3(x: 1, y: 1, z: 1)
      }
      
    } else {
      
      //Calculates distance based on the distance within the scene, as the location isn't yet confirmed
      adjustedDistance = Double(currentPosition.distance(to: placemark.position))
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
        placemark.billboardAnnotationNode?.scale = appliedScale
      } else {
        //Scale it to be an appropriate size so that it can be seen
        scale = Float(adjustedDistance) * 0.181
        
        if distance > 3000 {
          scale = scale * 0.75
        }
        placemark.billboardAnnotationNode?.scale = SCNVector3(x: scale, y: scale, z: scale)
      }
      
      placemark.pivot = SCNMatrix4MakeTranslation(0, -1.1 * scale, 0)
    }
    
    SCNTransaction.commit()
  }
}

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
        
        // KAK TMP
        for savedLocation in SavedLocation.fetchAll() {
          self.add(savedLocation: savedLocation)
        }
        
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

