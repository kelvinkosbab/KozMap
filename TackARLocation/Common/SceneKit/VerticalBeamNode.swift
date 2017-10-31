//
//  VerticalBeamNode.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import SceneKit

class LocationNode : SCNNode {
  
  let savedLocation: SavedLocation
  
  init(savedLocation: SavedLocation) {
    self.savedLocation = savedLocation
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  ///Whether a node's position should be adjusted on an ongoing basis
  ///based on its' given location.
  ///This only occurs when a node's location is within 100m of the user.
  ///Adjustment doesn't apply to nodes without a confirmed location.
  ///When this is set to false, the result is a smoother appearance.
  ///When this is set to true, this means a node may appear to jump around
  ///as the user's location estimates update,
  ///but the position is generally more accurate.
  ///Defaults to true.
  public var continuallyAdjustNodePositionWhenWithinRange = true
}

class VerticalBeamNode : LocationNode {
  
  // MARK: - Properties
  
  ///Subnodes and adjustments should be applied to this subnode
  ///Required to allow scaling at the same time as having a 2D 'billboard' appearance
  let billboardAnnotationNode: SCNNode
  
  ///Whether the node should be scaled relative to its distance from the camera
  ///Default value (false) scales it to visually appear at the same size no matter the distance
  ///Setting to true causes annotation nodes to scale like a regular node
  ///Scaling relative to distance may be useful with local navigation-based uses
  ///For landmarks in the distance, the default is correct
  public var scaleRelativeToDistance = false
  
  // MARK: - Init
  
  override init(savedLocation: SavedLocation) {
    
    let image = #imageLiteral(resourceName: "assetGradient").withRenderingMode(.alwaysTemplate)
    let width = image.size.width / 100
    let height = image.size.height / 100
    let plane = SCNPlane(width: width, height: height)
    plane.firstMaterial?.diffuse.contents = image
    plane.firstMaterial?.lightingModel = .constant
    let billboardNode = SCNNode()
    billboardNode.geometry = plane
    billboardNode.position = SCNVector3(x: 0, y: Float(height) / 2, z: 0)
    self.billboardAnnotationNode = billboardNode
    
    let textGeometry = SCNText(string: savedLocation.name, extrusionDepth: 0)
    textGeometry.firstMaterial?.diffuse.contents = UIColor.orange
    textGeometry.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    let textNode = SCNNode()
    textNode.geometry = textGeometry
    textNode.scale = SCNVector3(x:  0.01, y:  0.01, z: 0.01)
    billboardNode.addChildNode(textNode)
    
    super.init(savedLocation: savedLocation)
    
    let billboardConstraint = SCNBillboardConstraint()
    billboardConstraint.freeAxes = .Y
    self.constraints = [ billboardConstraint ]
    
    self.addChildNode(billboardNode)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
