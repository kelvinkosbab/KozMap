//
//  FoodPlacemark+Util.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/9/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import Foundation
import CoreLocation

extension FoodPlacemark {
  
  // MARK: - Creating
  
  static func create(name: String, location: CLLocation, distance: Double?, uuid: String = UUID().uuidString) -> FoodPlacemark {
    let object = self.create()
    object.uuid = uuid
    object.placemarkType = .food
    let color = Color.red
    object.update(name: name, location: location, color: color, distance: distance)
    return object
  }
}
