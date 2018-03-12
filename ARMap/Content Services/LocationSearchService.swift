//
//  LocationSearchService.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/13/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

enum CoordinateSpan {
  case standard
  case small
  
  var value: MKCoordinateSpan{
    switch self {
    case .standard:
      return MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    case .small:
      return MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
    }
  }
}

struct LocationSearchService {
  
  func queryLocations(query: String?, currentLocation: CLLocation, coordinateSpan: CoordinateSpan = .standard, completion: @escaping (_ mapItems: [MapItem]) -> Void) {
    let request = MKLocalSearchRequest()
    request.naturalLanguageQuery = query
    request.region = MKCoordinateRegion(center: currentLocation.coordinate, span: coordinateSpan.value)
    let search = MKLocalSearch(request: request)
    search.start { (response, error) in
      
      // Parse the map items
      var mapItems: [MapItem] = []
      for mkMapItem in response?.mapItems ?? [] {
        if let _ = mkMapItem.placemark.location {
          let mapItem = MapItem(mkMapItem: mkMapItem, currentLocation: currentLocation)
          mapItems.append(mapItem)
        }
      }
      
      // Completion
      let sortedItems = mapItems.sorted { (item1, item2) -> Bool in
        if let distance1 = item1.distance, let distance2 = item2.distance {
          return distance1 < distance2
        } else if let _ = item1.distance {
          return true
        } else {
          return false
        }
      }
      completion(sortedItems)
    }
  }
}
