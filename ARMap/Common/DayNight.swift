//
//  DayNight.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/4/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import Foundation

struct DayNight {
  
  static var isNight: Bool {
    let currentHour = Calendar.current.component(.hour, from: Date())
    switch currentHour {
    case ..<8: // 8 AM
      return true
    case 17...:  // 6 PM
      return true
    default:
      return false
    }
  }
}
