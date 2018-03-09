//
//  MountainPlacemark+Util.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/8/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import Foundation
import CoreLocation

extension MountainPlacemark {
  
  // MARK: - Creating
  
  static func create(name: String, location: CLLocation, distance: Double?, uuid: String = UUID().uuidString) -> MountainPlacemark {
    let object = self.create()
    object.uuid = uuid
    object.placemarkType = .mountain
    let color = Color.white
    object.update(name: name, location: location, color: color, distance: distance)
    return object
  }
}
