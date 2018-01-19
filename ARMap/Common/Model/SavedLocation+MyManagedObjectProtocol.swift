//
//  SavedLocation+MyManagedObjectProtocol.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit
import CoreLocation

extension SavedLocation : MyManagedObjectProtocol {
  
  // MARK: - MyManagedObjectProtocol
  
  static var sortDescriptors: [NSSortDescriptor] {
    return [ NSSortDescriptor(key: "lastDistance", ascending: true), NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "date", ascending: true) ]
  }
  
  // MARK: - Creating
  
  static func create(name: String, location: CLLocation, color: Color, distance: Double?) -> SavedLocation {
    let object = self.create()
    object.update(name: name, location: location, color: color, distance: distance)
    return object
  }
  
  // MARK: - Helpers
  
  var location: CLLocation {
    get {
      return CLLocation(coordinate: self.coordinate, altitude: self.altitude, horizontalAccuracy: self.horizontalAccuracy, verticalAccuracy: self.verticalAccuracy, course: self.course, speed: self.speed, timestamp: self.date ?? Date())
    }
    set {
      self.coordinate = newValue.coordinate
      self.altitude = newValue.altitude
      self.horizontalAccuracy = newValue.horizontalAccuracy
      self.verticalAccuracy = newValue.verticalAccuracy
      self.course = newValue.course
      self.speed = newValue.speed
      self.date = newValue.timestamp
    }
  }
  
  var coordinate: CLLocationCoordinate2D {
    get {
      return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    set {
      self.latitude = newValue.latitude
      self.longitude = newValue.longitude
    }
  }
  
  var hasLastDistance: Bool {
    return self.lastDistance > 0
  }
  
  // MARK: - Updating
  
  func update(name: String, location: CLLocation, color: Color, distance: Double?) {
    self.name = name
    self.location = location
    if let oldColor = self.color, oldColor != color {
      Color.deleteOne(oldColor)
    }
    self.color = color
    self.lastDistance = distance ?? -1
  }
}
