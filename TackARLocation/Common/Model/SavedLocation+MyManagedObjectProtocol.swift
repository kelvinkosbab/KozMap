//
//  SavedLocation+MyManagedObjectProtocol.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit
import CoreLocation

extension SavedLocation : MyManagedObjectProtocol {
  
  // MARK: - MyManagedObjectProtocol
  
  static var sortDescriptors: [NSSortDescriptor] {
    return [ NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "date", ascending: true) ]
  }
  
  // MARK: - Creating
  
  static func create(name: String, latitude: Double, longitude: Double, altitude: Double, horizontalAccuracy: Double, verticalAccuracy: Double, course: Double, speed: Double, date: Date, color: Color) -> SavedLocation {
    let object = self.create()
    object.name = name
    object.latitude = latitude
    object.longitude = longitude
    object.altitude = altitude
    object.horizontalAccuracy = horizontalAccuracy
    object.verticalAccuracy = verticalAccuracy
    object.course = course
    object.speed = speed
    object.date = date
    object.color = color
    return object
  }
  
  static func create(name: String, location: CLLocation, color: Color) -> SavedLocation {
    let coordinate = location.coordinate
    return self.create(name: name, latitude: coordinate.latitude, longitude: coordinate.longitude, altitude: location.altitude, horizontalAccuracy: location.horizontalAccuracy, verticalAccuracy: location.verticalAccuracy, course: location.course, speed: location.speed, date: location.timestamp, color: color)
  }
  
  // MARK: - Helpers
  
  var location: CLLocation {
    return CLLocation(coordinate: self.coordinate, altitude: self.altitude, horizontalAccuracy: self.horizontalAccuracy, verticalAccuracy: self.verticalAccuracy, course: self.course, speed: self.speed, timestamp: self.date ?? date ?? Date())
  }
  
  var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
  }
}
