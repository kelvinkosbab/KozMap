//
//  Placemark+CoreLocation.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/7/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import CoreLocation

extension Placemark {
  
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
}
