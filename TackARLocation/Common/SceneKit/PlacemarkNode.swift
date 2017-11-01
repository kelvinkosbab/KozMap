//
//  PlacemarkNode.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 11/1/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import SceneKit

class PlacemarkNode : VirtualObject {
  
  init() {
    super.init(modelName: "CylinderNode", fileExtension: "scn")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var nameTextNode: SCNNode? {
    return self.childNode(withName: "nameText", recursively: true)
  }
  
  var distanceTextNode: SCNNode? {
    return self.childNode(withName: "distanceText", recursively: true)
  }
  
  var unitTextNode: SCNNode? {
    return self.childNode(withName: "unitText", recursively: true)
  }
  
  var beamNode: SCNNode? {
    return self.childNode(withName: "beam", recursively: true)
  }
}
