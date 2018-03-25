//
//  UnitType.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import Foundation

enum UnitType : Int16 {
  case imperial, metric
  
  var string: String {
    switch self {
    case .imperial:
      return "Imperial"
    case .metric:
      return "Metric"
    }
  }
  
  var farName: String {
    switch self {
    case .imperial:
      return "Miles"
    case .metric:
      return "Kilometers"
    }
  }
  
  var farNameShort: String {
    switch self {
    case .imperial:
      return "Mi"
    case .metric:
      return "Km"
    }
  }
  
  var nearName: String {
    switch self {
    case .imperial:
      return "Feet"
    case .metric:
      return "Meters"
    }
  }
  
  var nearNameShort: String {
    switch self {
    case .imperial:
      return "Ft"
    case .metric:
      return "m"
    }
  }
}
