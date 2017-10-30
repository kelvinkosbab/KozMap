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
  
  var name: String {
    switch self {
    case .us:
      return "US"
    case .metric:
      return "Metric"
    }
  }
}
