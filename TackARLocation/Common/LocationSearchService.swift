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
        let mapItem = MapItem(mkMapItem: mkMapItem)
        mapItems.append(mapItem)
      }
      
      // Completion
      completion(mapItems)
    }
  }
}
