//
//  Double+Util.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation

extension Double {
  
  // MARK: - Helpers
  
  var oneDecimal: Double {
    return Double(Int(self*100)/100)
  }
  
  var twoDecimal: Double {
    return Double(Int(self*1000)/1000)
  }
  
  var threeDecimal: Double {
    return Double(Int(self*10000)/10000)
  }
  
  // MARK: - Distance
  
  static let shortDistanceCutoff: Double = 1000
  
  func getDistanceValue(unitType: UnitType, asShortValue: Bool = false) -> String {
    switch self {
    case ..<Double.shortDistanceCutoff:
      switch unitType {
      case .imperial:
        let feet = self * 3.28084 // 1m == 3.28084ft
        return "\(Int(feet))"
      case .metric:
        return "\(Int(self))"
      }
      
    default:
      let kilometers = self / 1000
      switch unitType {
      case .imperial:
        let miles = kilometers * 0.621371 // 1km == 0.621371mi
        return "\(asShortValue ? miles.oneDecimal : miles.threeDecimal)"
      case .metric:
        return "\(asShortValue ? kilometers.oneDecimal : kilometers.threeDecimal)"
      }
    }
  }
  
  func getUnitTypeString(unitType: UnitType, asShortString: Bool = false) -> String {
    switch self {
    case ..<Double.shortDistanceCutoff:
      return asShortString ? unitType.nearNameShort : unitType.nearName
    default:
      return asShortString ? unitType.farNameShort : unitType.farName
    }
  }
  
  func getBasicReadibleDistance(unitType: UnitType) -> String {
    let distanceValue = self.getDistanceValue(unitType: unitType)
    let unitTypeString = self.getUnitTypeString(unitType: unitType)
    return "\(distanceValue) \(unitTypeString)"
  }
}
