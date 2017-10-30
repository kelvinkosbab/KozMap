//
//  SavedLocation+MyManagedObjectProtocol.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import CoreLocation

extension SavedLocation : MyManagedObjectProtocol {
  
  // MARK: - MyManagedObjectProtocol
  
  static var sortDescriptors: [NSSortDescriptor] {
    return [ NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "date", ascending: true) ]
  }
  
  // MARK: - Creating
  
  static func create(name: String, latitude: Double, longitude: Double) -> SavedLocation {
    let object = self.create()
    object.date = Date()
    object.name = name
    object.latitude = latitude
    object.longitude = longitude
    return object
  }
  
  static func create(name: String, location: CLLocation) -> SavedLocation {
    let coordinate = location.coordinate
    return self.create(name: name, latitude: coordinate.latitude, longitude: coordinate.longitude)
  }
}
