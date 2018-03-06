//
//  AnalyticsScreen.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/5/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import Foundation

enum AnalyticsScreen {
  case placemarkList
  case placemarkDetail
  case addPlacemark
  case settings
  
  var name: String {
    switch self {
    case .placemarkList:
      return "Placemark List"
    case .placemarkDetail:
      return "Placemark Detail"
    case .addPlacemark:
      return "Add Placemark"
    case .settings:
      return "Settings"
    }
  }
}
