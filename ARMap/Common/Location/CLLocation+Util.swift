//
//  CLLocation+Util.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 1/20/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import Foundation
import CoreLocation

// Translation in meters between 2 locations
struct LocationTranslation {
  var latitudeTranslation: Double
  var longitudeTranslation: Double
  var altitudeTranslation: Double
}

extension CLLocation {
  
  convenience init(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance) {
    self.init(coordinate: coordinate, altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
  }
  
  // Translates distance in meters between two locations and returns the result as the distance in latitude and distance in longitude.
  func translation(toLocation location: CLLocation) -> LocationTranslation {
    let inbetweenLocation = CLLocation(latitude: self.coordinate.latitude, longitude: location.coordinate.longitude)
    let distanceLatitude = location.distance(from: inbetweenLocation)
    let latitudeTranslation: Double = location.coordinate.latitude > inbetweenLocation.coordinate.latitude ? distanceLatitude : -distanceLatitude
    let distanceLongitude = self.distance(from: inbetweenLocation)
    let longitudeTranslation: Double = self.coordinate.longitude > inbetweenLocation.coordinate.longitude ? -distanceLongitude : distanceLongitude
    let altitudeTranslation = location.altitude - self.altitude
    
    return LocationTranslation(latitudeTranslation: latitudeTranslation, longitudeTranslation: longitudeTranslation, altitudeTranslation: altitudeTranslation)
  }
  
  func translatedLocation(with translation: LocationTranslation) -> CLLocation {
    let latitudeCoordinate = self.coordinate.coordinateWithBearing(bearing: 0, distanceMeters: translation.latitudeTranslation)
    let longitudeCoordinate = self.coordinate.coordinateWithBearing(bearing: 90, distanceMeters: translation.longitudeTranslation)
    let coordinate = CLLocationCoordinate2D(latitude: latitudeCoordinate.latitude, longitude: longitudeCoordinate.longitude)
    let altitude = self.altitude + translation.altitudeTranslation
    return CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: self.horizontalAccuracy, verticalAccuracy: self.verticalAccuracy, timestamp: self.timestamp)
  }
  
  func getPlacemark(completion: @escaping (_ placemark: CLPlacemark?) -> Void) {
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(self) { (placemarks, error) in
      if let error = error {
        Log.log("An error occurred: \(error.localizedDescription)")
        completion(nil)
      } else {
        let firstPlacemark = placemarks?.first
        completion(firstPlacemark)
      }
    }
  }
}
