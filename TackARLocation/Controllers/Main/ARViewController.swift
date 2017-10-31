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
  private var locationNodes = Set<LocationNode>()
  
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
        self.updatePositionAndScaleOfLocationNodes()
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
  
  func addLocationNode(savedLocation: SavedLocation) {
    let locationNode = VerticalBeamNode(savedLocation: savedLocation)
    self.addLocationNode(locationNode: locationNode)
  }
  
  func removeLocationNode(savedLocation: SavedLocation) {
    self.sceneView.scene.rootNode.enumerateChildNodes { (child, _) in
      if let locationNode = child as? LocationNode, locationNode.savedLocation == savedLocation {
        locationNode.removeFromParentNode()
      }
    }
  }
  
  ///location not being nil, and locationConfirmed being true are required
  ///Upon being added, a node's position will be modified and should not be changed externally.
  ///location will not be modified, but taken as accurate.
  private func addLocationNode(locationNode: LocationNode) {
    self.updatePositionAndScaleOfLocationNode(locationNode: locationNode, initialSetup: true, animated: false)
    self.locationNodes.insert(locationNode)
    self.sceneNode?.addChildNode(locationNode)
  }
  
  private func updatePositionAndScaleOfLocationNodes() {
    for locationNode in self.locationNodes {
      self.updatePositionAndScaleOfLocationNode(locationNode: locationNode, animated: true)
    }
  }
  
  ///Gives the best estimate of the location of a node
  private func getLocation(locationNode: LocationNode) -> CLLocation {
    return locationNode.savedLocation.location
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
  
  func updatePositionAndScaleOfLocationNode(locationNode: LocationNode, initialSetup: Bool = false, animated: Bool = false, duration: TimeInterval = 0.1) {
    
    guard let currentPosition = self.currentScenePosition, let currentLocation = self.currentLocation else {
        return
    }
    
    SCNTransaction.begin()
    
    if animated {
      SCNTransaction.animationDuration = duration
    } else {
      SCNTransaction.animationDuration = 0
    }
    
    // Core location of this node
    let locationNodeLocation = self.getLocation(locationNode: locationNode)
    
    //Position is set to a position coordinated via the current position
    let locationTranslation = currentLocation.translation(toLocation: locationNodeLocation)
    
    let adjustedDistance: CLLocationDistance
    
    let distance = locationNodeLocation.distance(from: currentLocation)
    
    if distance > 100 || locationNode.continuallyAdjustNodePositionWhenWithinRange || initialSetup {
      if distance > 100 {
        //If the item is too far away, bring it closer and scale it down
        let scale = 100 / Float(distance)
        
        adjustedDistance = distance * Double(scale)
        
        let adjustedTranslation = SCNVector3(
          x: Float(locationTranslation.longitudeTranslation) * scale,
          y: Float(locationTranslation.altitudeTranslation) * scale,
          z: Float(locationTranslation.latitudeTranslation) * scale)
        
        let position = SCNVector3(
          x: currentPosition.x + adjustedTranslation.x,
          y: currentPosition.y + adjustedTranslation.y,
          z: currentPosition.z - adjustedTranslation.z)
        
        locationNode.position = position
        
        locationNode.scale = SCNVector3(x: scale, y: scale, z: scale)
      } else {
        adjustedDistance = distance
        let position = SCNVector3(
          x: currentPosition.x + Float(locationTranslation.longitudeTranslation),
          y: currentPosition.y + Float(locationTranslation.altitudeTranslation),
          z: currentPosition.z - Float(locationTranslation.latitudeTranslation))
        
        locationNode.position = position
        locationNode.scale = SCNVector3(x: 1, y: 1, z: 1)
      }
      
    } else {
      
      //Calculates distance based on the distance within the scene, as the location isn't yet confirmed
      adjustedDistance = Double(currentPosition.distance(to: locationNode.position))
      
      locationNode.scale = SCNVector3(x: 1, y: 1, z: 1)
    }
    
    if let beamNode = locationNode as? VerticalBeamNode {
      //The scale of a node with a billboard constraint applied is ignored
      //The annotation subnode itself, as a subnode, has the scale applied to it
      let appliedScale = locationNode.scale
      locationNode.scale = SCNVector3(x: 1, y: 1, z: 1)
      
      var scale: Float
      
      if beamNode.scaleRelativeToDistance {
        scale = appliedScale.y
        beamNode.billboardAnnotationNode.scale = appliedScale
      } else {
        //Scale it to be an appropriate size so that it can be seen
        scale = Float(adjustedDistance) * 0.181
        
        if distance > 3000 {
          scale = scale * 0.75
        }
        beamNode.billboardAnnotationNode.scale = SCNVector3(x: scale, y: scale, z: scale)
      }
      
      beamNode.pivot = SCNMatrix4MakeTranslation(0, -1.1 * scale, 0)
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
          let locationNode = VerticalBeamNode(savedLocation: savedLocation)
          self.addLocationNode(locationNode: locationNode)
        }
      
      default: break
      }
    }
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    self.extendedLog("session was interrupted")
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    self.extendedLog("session interruption ended")
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    self.extendedLog("session did fail with error: \(error)")
  }
  
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    self.currentCameraTrackingState = camera.trackingState
    switch camera.trackingState {
    case .limited(.insufficientFeatures):
      self.extendedLog("camera did change tracking state: limited, insufficient features")
    case .limited(.excessiveMotion):
      self.extendedLog("camera did change tracking state: limited, excessive motion")
    case .limited(.initializing):
      self.extendedLog("camera did change tracking state: limited, initializing")
    case .normal:
      self.extendedLog("camera did change tracking state: normal")
    case .notAvailable:
      self.extendedLog("camera did change tracking state: not available")
    }
  }
}
