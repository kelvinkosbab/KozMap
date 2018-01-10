//
//  BuildManager.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 1/10/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import Foundation

class BuildManager {
  
  // MARK: - Singleton
  
  static let shared = BuildManager()
  
  private init() {}
  
  // MARK: - Company
  
  var company: AppCompany {
    #if KOZINGA
      return .kozinga
    #else
      return .tack
    #endif
  }
  
  // MARK: - Debug Build vs Release Build
  
  static var isDebugBuild: Bool {
    #if DEBUG
      return true
    #else
      return false
    #endif
  }
  
  static var isReleaseBuild: Bool {
    return !self.isDebugBuild
  }
}
