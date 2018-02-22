//
//  BuildManager.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 1/10/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import Foundation

enum BuidTarget {
  case tackmobile, kozinga
  
  var appName: String {
    switch self {
    case .tackmobile:
      return "ARMap"
    case .kozinga:
      return "Koz Map"
    }
  }
  
  var companyName: String {
    switch self {
    case .tackmobile:
      return "©Tack Mobile"
    case .kozinga:
      return "©Kozinga"
    }
  }
}

class BuildManager {
  
  // MARK: - Singleton
  
  static let shared = BuildManager()
  
  private init() {}
  
  // MARK: - Debug Build vs Release Build
  
  var isDebugBuild: Bool {
    #if DEBUG
      return true
    #else
      return false
    #endif
  }
  
  var isReleaseBuild: Bool {
    return !self.isDebugBuild
  }
  
  // MARK: - Build Target
  
  var buildTarget: BuidTarget {
    #if KOZINGA
    return .kozinga
    #else
    return .tackmobile
    #endif
  }
}
