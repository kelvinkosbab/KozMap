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
