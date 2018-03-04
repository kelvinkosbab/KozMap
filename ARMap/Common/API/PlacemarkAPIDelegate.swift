//
//  PlacemarkAPIDelegate.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/3/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import Foundation

protocol PlacemarkAPIDelegate : class {}
extension PlacemarkAPIDelegate {
  
  func deletePlacemark(_ placemark: Placemark) {
    
    // Delete this location from core data
    Placemark.deleteOne(placemark)
  }
}
