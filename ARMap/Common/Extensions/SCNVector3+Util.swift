//
//  SCNVector3+Util.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/31/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import SceneKit

extension SCNVector3 {
  
  ///Calculates distance between vectors
  ///Doesn't include the y axis, matches functionality of CLLocation 'distance' function.
  func distance(to anotherVector: SCNVector3) -> Float {
    return sqrt(pow(anotherVector.x - x, 2) + pow(anotherVector.z - z, 2))
  }
}
