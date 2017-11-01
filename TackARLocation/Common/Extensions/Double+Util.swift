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
  
  func getDistanceValue(nearUnitType: UnitType, farUnitType: UnitType, asShortValue: Bool = false) -> String {
    switch self {
    case ..<Double.shortDistanceCutoff:
      switch nearUnitType {
      case .us:
        let feet = self * 3.28084 // 1m == 3.28084ft
        return "\(Int(feet))"
      case .metric:
        return "\(Int(self))"
      }
      
    default:
      let kilometers = self / 1000
      switch farUnitType {
      case .us:
        let miles = kilometers * 0.621371 // 1km == 0.621371mi
        return "\(asShortValue ? miles.oneDecimal : miles.threeDecimal)"
      case .metric:
        return "\(asShortValue ? kilometers.oneDecimal : kilometers.threeDecimal)"
      }
    }
  }
  
  func getUnitTypeString(nearUnitType: UnitType, farUnitType: UnitType, asShortString: Bool = false) -> String {
    switch self {
    case ..<Double.shortDistanceCutoff:
      return asShortString ? nearUnitType.nearNameShort : nearUnitType.nearName
    default:
      return asShortString ? farUnitType.farNameShort : farUnitType.farName
    }
  }
  
  func getBasicReadibleDistance(nearUnitType: UnitType, farUnitType: UnitType) -> String {
    let distanceValue = self.getDistanceValue(nearUnitType: nearUnitType, farUnitType: farUnitType)
    let unitTypeString = self.getUnitTypeString(nearUnitType: nearUnitType, farUnitType: farUnitType)
    return "\(distanceValue) \(unitTypeString)"
  }
}
