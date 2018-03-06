//
//  AnalyticsItem.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/5/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import Foundation

enum AnalyticsItem: String {
  case totalPlacemarks
  
  static let all: [AnalyticsItem] = [ .totalPlacemarks ]
  
  var value: String {
    switch self {
    case .totalPlacemarks:
      return "\(Placemark.fetchAll().count)"
    }
  }
}
