//
//  PinPlacemarkNode.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/26/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import SceneKit

class PinPlacemarkNode : PlacemarkNode {
  
  override var modelName: String {
    return "PinPlacemarkNode"
  }
  
  // MARK: - Child Nodes
  
  private var pinBannerNode: SCNNode? {
    return self.childNode(withName: "pinBannerNode", recursively: true)
  }
  
  override func updatePrimaryName() {
    super.updatePrimaryName()
    
    if let nameTextNode = self.nameTextNode {
      let dx = -(nameTextNode.boundingBox.max.x - nameTextNode.boundingBox.min.x) * nameTextNode.scale.x / 2
      nameTextNode.position = SCNVector3(x: dx, y: nameTextNode.position.y, z: nameTextNode.position.z)
    }
  }
  
  override func updateBeamColor() {
    super.updateBeamColor()
    
    self.pinBannerNode?.geometry?.firstMaterial?.diffuse.contents = self.beamColor
  }
  
  override func updateBeamTransparency() {
    super.updateBeamTransparency()
    
    self.pinBannerNode?.geometry?.firstMaterial?.transparency = self.beamTransparency
  }
}
