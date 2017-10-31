//
//  UnitType.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation

enum UnitType : Int {
  case us, metric
  
  var farName: String {
    switch self {
    case .us:
      return "Miles"
    case .metric:
      return "Kilometers"
    }
  }
  
  var nearName: String {
    switch self {
    case .us:
      return "Feet"
    case .metric:
      return "Meters"
    }
  }
}
