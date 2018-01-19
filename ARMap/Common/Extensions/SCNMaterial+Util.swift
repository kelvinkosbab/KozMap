//
//  SCNMaterial+Util.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
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
