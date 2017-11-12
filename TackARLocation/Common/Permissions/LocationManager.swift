//
//  LocationManager.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import CoreLocation

/*
 * Handles retrieving the location and heading from CoreLocation
 */

protocol LocationManagerDelegate : class {
  func locationManagerDidUpdateLocation(_ locationManager: LocationManager, location: CLLocation)
  func locationManagerDidUpdateHeading(_ locationManager: LocationManager, heading: CLLocationDirection, accuracy: CLLocationDirection)
}

protocol LocationManagerAuthorizationDelegate : class {
  func locationManagerDidUpdateAuthorization()
}

class LocationManager : NSObject, CLLocationManagerDelegate, PermissionManagerDelegate {
  
  // MARK: - Singleton
  
  static let shared = LocationManager()
  
  private override init() {
    
    let locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.headingFilter = kCLHeadingFilterNone
    locationManager.pausesLocationUpdatesAutomatically = false
    locationManager.startUpdatingHeading()
    locationManager.startUpdatingLocation()
    self.locationManager = locationManager
    
    super.init()
    
    self.locationManager.delegate = self
    self.currentLocation = self.locationManager.location
    if let heading = self.locationManager.heading {
      if heading.headingAccuracy >= 0 {
        self.heading = heading.trueHeading
      } else {
        self.heading = heading.magneticHeading
      }
    }
  }
  
  // MARK: - PermissionManagerDelegate
  
  var status: PermissionAuthorizationStatus {
    switch self.clAuthorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      return .authorized
    case .denied, .restricted:
      return .denied
    case .notDetermined:
      return .notDetermined
    }
  }
  
  // MARK: - Properties / Init
  
  weak var delegate: LocationManagerDelegate? = nil
  weak var authorizationDelegate: LocationManagerAuthorizationDelegate? = nil
  
  private let locationManager: CLLocationManager
  
  var currentLocation: CLLocation?
  var heading: CLLocationDirection?
  var headingAccuracy: CLLocationDegrees?
  
  // MARK: - Permissions
  
  private var clAuthorizationStatus: CLAuthorizationStatus {
    return CLLocationManager.authorizationStatus()
  }
  
  var isAccessAuthorized: Bool {
    switch self.clAuthorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      return true
    case .denied, .restricted, .notDetermined:
      return false
    }
  }
  
  var isAccessDenied: Bool {
    switch self.clAuthorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
      return false
    case .denied, .restricted:
      return true
    }
  }
  
  var isAccessNotDetermined: Bool {
    return self.clAuthorizationStatus == .notDetermined
  }
  
  // MARK: - Authorization
  
  func requestAuthorization() {
    switch CLLocationManager.authorizationStatus() {
    case .authorizedAlways, .authorizedWhenInUse:
      return
    case .denied, .restricted:
      return
    case .notDetermined:
      self.locationManager.requestWhenInUseAuthorization()
    }
  }
  
  // MARK: - CLLocationManagerDelegate
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    self.authorizationDelegate?.locationManagerDidUpdateAuthorization()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    for location in locations {
      self.delegate?.locationManagerDidUpdateLocation(self, location: location)
    }
    
    self.currentLocation = manager.location
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    if newHeading.headingAccuracy >= 0 {
      self.heading = newHeading.trueHeading
    } else {
      self.heading = newHeading.magneticHeading
    }
    
    self.headingAccuracy = newHeading.headingAccuracy
    
    self.delegate?.locationManagerDidUpdateHeading(self, heading: self.heading!, accuracy: newHeading.headingAccuracy)
  }
  
  func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
    return true
  }
}
