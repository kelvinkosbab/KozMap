//
//  CLLocation+Util.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/31/17.
//  Copyright © 2017 Kozinga. All rights reserved.
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
}

fileprivate extension Double {
  
  var metersToLatitude: Double {
    return self / 6360500.0
  }
  
  var metersToLongitude: Double {
    return self / 5602900.0
  }
}

extension CLLocationCoordinate2D {
  
  func coordinateWithBearing(bearing: Double, distanceMeters: Double) -> CLLocationCoordinate2D {
    //The numbers for earth radius may be _off_ here
    //but this gives a reasonably accurate result..
    //Any correction here is welcome.
    let distRadiansLat = distanceMeters.metersToLatitude // earth radius in meters latitude
    let distRadiansLong = distanceMeters.metersToLongitude // earth radius in meters longitude
    
    let lat1 = self.latitude * .pi / 180
    let lon1 = self.longitude * .pi / 180
    
    let lat2 = asin(sin(lat1) * cos(distRadiansLat) + cos(lat1) * sin(distRadiansLat) * cos(bearing))
    let lon2 = lon1 + atan2(sin(bearing) * sin(distRadiansLong) * cos(lat1), cos(distRadiansLong) - sin(lat1) * sin(lat2))
    
    return CLLocationCoordinate2D(latitude: lat2 * 180 / .pi, longitude: lon2 * 180 / .pi)
  }
}
