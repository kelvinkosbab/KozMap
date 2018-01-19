//
//  Defaults+MyManagedObjectProtocol.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import Foundation
import CoreData

extension Defaults : MyManagedObjectProtocol {
  
  // MARK: - MyManagedObjectProtocol
  
  static var sortDescriptors: [NSSortDescriptor] {
    return [ NSSortDescriptor(key: "unitTypeValue", ascending: true) ]
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
}
