//
//  MapItem.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/16/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

extension MKPlacemark {
  
  var streetNumber: String? {
    return self.subThoroughfare
  }
  
  var streetName: String? {
    return self.thoroughfare
  }
  
  var cityName: String? {
    return self.locality
  }
  
  var stateName: String? {
    return self.administrativeArea
  }
  
  var address: String? {
    
    // Space between street number and street name
    let firstSpace = (self.subThoroughfare != nil && self.thoroughfare != nil) ? " " : ""
    // Comma between street and city/state
    let comma = (self.subThoroughfare != nil || self.thoroughfare != nil) && (self.subAdministrativeArea != nil || self.administrativeArea != nil) ? ", " : ""
    // Space between city and state
    let secondSpace = (self.subAdministrativeArea != nil && self.administrativeArea != nil) ? " " : ""
    
    // Construct the address
    let streetNumber: String = self.subThoroughfare ?? ""
    let streetName: String = self.thoroughfare ?? ""
    let cityName: String = self.locality ?? ""
    let stateName: String = self.administrativeArea ?? ""
    return "\(streetNumber)\(firstSpace)\(streetName)\(comma)\(cityName)\(secondSpace)\(stateName)"
  }
}

struct MapItem {
  let mkMapItem: MKMapItem
  var currentLocation: CLLocation?
  
  var name: String? {
    return self.mkMapItem.name
  }
  
  var placemark: MKPlacemark {
    return self.mkMapItem.placemark
  }
  
  var isCurrentLocation: Bool {
    return self.mkMapItem.isCurrentLocation
  }
  
  var phoneNumber: String? {
    return self.mkMapItem.phoneNumber
  }
  
  var url: URL? {
    return self.mkMapItem.url
  }
  
  var timeZone: TimeZone? {
    return self.mkMapItem.timeZone
  }
  
  var address: String? {
    return self.placemark.address
  }
  
  var distance: Double? {
    if let mapItemLocation = self.mkMapItem.placemark.location {
      return self.currentLocation?.distance(from: mapItemLocation)
    }
    return nil
  }
}
