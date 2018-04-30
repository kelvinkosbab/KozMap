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
      if let unitType = UnitType(rawValue: self.unitTypeValue) {
        return unitType
      }
      
      // Set default unit type
      self.unitType = .imperial
      return self.unitType
    }
    set {
      self.unitTypeValue = newValue.rawValue
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
  
  // MARK: - Daytime / Nightime Colors
  
  var dayTextColor: Color {
    get {
      if let color = self.daytimeTextColorValue {
        return color
      }
      
      self.dayTextColor = Color.black
      return self.dayTextColor
    }
    set {
      if let oldValue = self.daytimeTextColorValue {
        oldValue.managedObjectContext?.delete(oldValue)
      }
      self.daytimeTextColorValue = newValue
    }
  }
  
  var nightTextColor: Color {
    get {
      if let color = self.nighttimeTextColorValue {
        return color
      }
      
      self.nightTextColor = Color.white
      return self.nightTextColor
    }
    set {
      if let oldValue = self.nighttimeTextColorValue {
        oldValue.managedObjectContext?.delete(oldValue)
      }
      self.nighttimeTextColorValue = newValue
    }
  }
  
  // MARK: - Food Nearby
  
  var defaultFoodSearchText: String {
    return "restaurants"
  }
}
