//
//  LocationSearchService.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/13/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

extension MKCoordinateSpan {
  static let standard = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
}

struct LocationSearchService {
  
  func queryLocations(query: String?, currentLocation: CLLocation, completion: @escaping (_ mapItems: [MapItem]) -> Void) {
    let request = MKLocalSearchRequest()
    request.naturalLanguageQuery = query
    request.region = MKCoordinateRegion(center: currentLocation.coordinate, span: MKCoordinateSpan.standard)
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
