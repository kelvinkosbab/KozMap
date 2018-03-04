//
//  CLPlacemark+Util.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 1/21/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import Foundation
import CoreLocation

extension CLPlacemark {
  
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
