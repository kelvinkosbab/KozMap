//
//  AppCompany.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 1/10/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import Foundation

enum AppCompany {
  case kozinga, tack
  
  var bundleId: String {
    switch self {
    case .kozinga:
      return "com.kozinga.KozMap"
    case .tack:
      return "com.tackmobile.ARMap"
    }
  }
  
  var displayName: String {
    switch self {
    case .kozinga:
      return "KozMap"
    case .tack:
      return "ARMap"
    }
  }
}
