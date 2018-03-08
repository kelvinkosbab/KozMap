//
//  Placemark+Util.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/7/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import CoreLocation

extension Placemark {
  
  // MARK: - Helpers
  
  var hasLastDistance: Bool {
    return self.lastDistance > 0
  }
  
  // MARK: - Updating
  
  func update(name: String, location: CLLocation, color: Color, distance: Double?) {
    self.name = name
    self.location = location
    if let oldColor = self.color, oldColor != color {
      Color.deleteOne(oldColor)
    }
    self.color = color
    self.lastDistance = distance ?? -1
  }
}
