//
//  CLLocation+Solar.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/4/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import CoreLocation
import Solar

extension CLLocation {
  
  private var solar: Solar? {
    let date = Date()
    return Solar(for: date, coordinate: self.coordinate)
  }
  
  var sunrise: Date? {
    return self.solar?.sunrise
  }
  
  var sunset: Date? {
    return self.solar?.sunset
  }
  
  var isDayTime: Bool {
    return self.solar?.isDaytime ?? false
  }
  
  var isNightTime: Bool {
    return self.solar?.isNighttime ?? true
  }
}

