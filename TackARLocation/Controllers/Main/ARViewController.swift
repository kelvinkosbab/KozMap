//
//  ARViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit
import ARKit

class ARViewController : UIViewController {
  
  // MARK: - Properties
  
  @IBOutlet weak var sceneView: ARSCNView!
  
  private let session = ARSession()
  private let sessionConfig = ARWorldTrackingConfiguration()
  public private(set) weak var sceneNode: SCNNode?
  
  var scneViewCenter: CGPoint {
    return self.sceneView.bounds.mid
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
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    self.session.pause()
  }
  
  // MARK: - Scene
  
  func restartPlaneDetection() {
    
    // Configure session
    self.sessionConfig.planeDetection = .horizontal
    self.sessionConfig.isLightEstimationEnabled = true
    self.sessionConfig.worldAlignment = .gravityAndHeading
    self.session.run(self.sessionConfig, options: [.resetTracking, .removeExistingAnchors])
  }
}

extension ARViewController : ARSCNViewDelegate {
  
  public func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
    if self.sceneNode == nil {
      let node = SCNNode()
      self.sceneNode = node
      scene.rootNode.addChildNode(node)
      
//      if showAxesNode {
        let axesNode = SCNNode.axesNode(quiverLength: 0.1, quiverThickness: 0.5)
        self.sceneNode?.addChildNode(axesNode)
//      }
    }
    
//    if !didFetchInitialLocation {
//      //Current frame and current location are required for this to be successful
//      if session.currentFrame != nil,
//        let currentLocation = self.locationManager.currentLocation {
//        didFetchInitialLocation = true
//
//        self.addSceneLocationEstimate(location: currentLocation)
//      }
//    }
  }
  
  public func sessionWasInterrupted(_ session: ARSession) {
    self.extendedLog("session was interrupted")
  }
  
  public func sessionInterruptionEnded(_ session: ARSession) {
    self.extendedLog("session interruption ended")
  }
  
  public func session(_ session: ARSession, didFailWithError error: Error) {
    self.extendedLog("session did fail with error: \(error)")
  }
  
  public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
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
