//
//  CrashManager.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/5/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import Fabric
import Firebase

/*
 * Build Manager is responsible for handling any build and crash tools
 *
 * Currently Includes:
 *  - Crashlytics
 */

class CrashManager {
  
  // MARK: - Singleton
  
  static let shared: CrashManager = CrashManager()
  
  private init() {}
  
  // MARK: - App Launch
  
  func appDidFinishLaunching() {
    
    // Start Crashlytics crash reporting
    Fabric.with([ Crashlytics.self ])
  }
}
