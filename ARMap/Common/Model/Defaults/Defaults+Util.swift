//
//  Defaults+Util.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/10/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import Foundation

extension Defaults {
  
  // MARK: - Singleton
  
  private static var _shared: Defaults? = nil
  
  static var shared: Defaults {
    
    // Check if there is already a fetched reference
    if let shared = self._shared {
      return shared
    }
    
    // Need to fetch / create
    let shared = self.fetchAll().first ?? self.create()
    self._shared = shared
    MyDataManager.shared.saveMainContext()
    return shared
  }
  
  // MARK: - Helpers
  
  var unitType: UnitType {
    get {
      if let unitType = UnitType(rawValue: Int(self.unitTypeValue)) {
        return unitType
      }
      
      // Set default unit type
      self.unitType = .imperial
      return self.unitType
    }
    set {
      self.unitTypeValue = Int16(newValue.rawValue)
      MyDataManager.shared.saveMainContext()
    }
  }
  
  var appMode: AppMode {
    get {
      if let appMode = AppMode(rawValue: self.appModeValue) {
        return appMode
      }
      
      // Set default unit type
      self.appMode = .myPlacemark
      return self.appMode
    }
    set {
      self.appModeValue = newValue.rawValue
      MyDataManager.shared.saveMainContext()
    }
  }
}
