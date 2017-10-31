//
//  Defaults+MyManagedObjectProtocol.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import CoreData

extension Defaults : MyManagedObjectProtocol {
  
  // MARK: - MyManagedObjectProtocol
  
  static var sortDescriptors: [NSSortDescriptor] {
    return [ NSSortDescriptor(key: "farUnitTypeValue", ascending: true) ]
  }
  
  // MARK: - Singleton
  
  private static var _shared: Defaults? = nil
  
  static var shared: Defaults {
    
    // Check if there is already a fetched reference
    if let shared = self._shared {
      return shared
    }
    
    // Need to fetch / create
    let shared = self.fetchAll().first ?? self.create()
    MyDataManager.shared.saveMainContext()
    return shared
  }
  
  // MARK: - Helpers
  
  var farUnitType: UnitType {
    get {
      if let unitType = UnitType(rawValue: Int(self.farUnitTypeValue)) {
        return unitType
      }
      
      // Set default unit type
      self.farUnitType = .us
      return self.farUnitType
    }
    set {
      self.farUnitTypeValue = Int16(newValue.rawValue)
      MyDataManager.shared.saveMainContext()
    }
  }
  
  var nearUnitType: UnitType {
    get {
      if let unitType = UnitType(rawValue: Int(self.nearUnitTypeValue)) {
        return unitType
      }
      
      // Set default unit type
      self.nearUnitType = .us
      return self.nearUnitType
    }
    set {
      self.nearUnitTypeValue = Int16(newValue.rawValue)
      MyDataManager.shared.saveMainContext()
    }
  }
}
