//
//  SCNMaterial+Util.swift
// KozMap
//
//  Created by Kelvin Kosbab on 1/20/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import SceneKit

extension SCNMaterial {
  
  static var tron: SCNMaterial {
    let material = SCNMaterial()
    material.diffuse.contents = #imageLiteral(resourceName: "assetTron")
    return material
  }
  
  static var transparent: SCNMaterial {
    let material = SCNMaterial()
    material.diffuse.contents = UIColor(white: 1, alpha: 0)
    return material
  }
}
