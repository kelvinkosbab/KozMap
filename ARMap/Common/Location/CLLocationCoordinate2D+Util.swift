//
//  CLLocationCoordinate2D+Util.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 1/20/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import Foundation
import CoreLocation

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
