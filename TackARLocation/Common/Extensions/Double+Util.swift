//
//  Double+Util.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation

extension Double {
  
  func getReadibleDistance(nearUnitType: UnitType, farUnitType: UnitType) -> String {
    switch self {
    case ..<1000:
      switch nearUnitType {
      case .us:
        let feet = self * 3.28084 // 1m == 3.28084ft
        return "\(Int(feet)) feet"
      case .metric:
        return "\(Int(self)) meters"
      }
      
    default:
      let kilometers = self / 1000
      switch farUnitType {
      case .us:
        let miles = kilometers * 0.621371 // 1km == 0.621371mi
        return "\(miles.twoDecimal) miles"
      case .metric:
        return "\(kilometers.twoDecimal) kilometers"
      }
    }
  }
  
  private var twoDecimal: Double {
    return Double(Int(self*100)/100)
  }
}
