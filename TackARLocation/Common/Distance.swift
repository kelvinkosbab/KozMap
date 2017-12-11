//
//  Distance.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/19/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation

typealias Distance = Double

enum DistanceDisplayType {
  
  // Bool = is short string
  case numeric, units(Bool), numbericUnits(Bool)
}

extension Distance {
  
  func getDistanceString(unitType: UnitType, displayType: DistanceDisplayType) -> String? {
    
    // Check if valid distance
    guard self > 0 else {
      return nil
    }
    
    // Handle based on unit type
    switch unitType {
    case .imperial:
      let feet = self * 3.28084 // 1m == 3.28084ft
      if feet >= 1000 {
        let miles = feet / 5280
        switch displayType {
        case .numeric:
          return "\(miles.twoDecimal)"
        case .units(let isShort):
          return isShort ? unitType.farNameShort : unitType.farName
        case .numbericUnits(let isShort):
          return isShort ? "\(miles.twoDecimal) \(unitType.farNameShort)" : "\(miles.twoDecimal) \(unitType.farName)"
        }
      } else {
        switch displayType {
        case .numeric:
          return "\(Int(feet))"
        case .units(let isShort):
          return isShort ? unitType.nearNameShort : unitType.nearName
        case .numbericUnits(let isShort):
          return isShort ? "\(Int(feet)) \(unitType.nearNameShort)" : "\(Int(feet)) \(unitType.nearName)"
        }
      }
    case .metric:
      let meters = self
      if meters >= 1000 {
        let kilometers = meters / 1000
        switch displayType {
        case .numeric:
          return "\(kilometers.twoDecimal)"
        case .units(let isShort):
          return isShort ? unitType.farNameShort : unitType.farName
        case .numbericUnits(let isShort):
          return isShort ? "\(kilometers.twoDecimal) \(unitType.farNameShort)" : "\(kilometers.twoDecimal) \(unitType.farName)"
        }
      } else {
        switch displayType {
        case .numeric:
          return "\(Int(meters))"
        case .units(let isShort):
          return isShort ? unitType.nearNameShort : unitType.nearName
        case .numbericUnits(let isShort):
          return isShort ? "\(Int(meters)) \(unitType.nearNameShort)" : "\(Int(meters)) \(unitType.nearName)"
        }
      }
    }
  }
}
