//
//  Placemark+Type.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/9/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import Foundation

enum PlacemarkType : Int16 {
  case myPlacemark = 0
  case mountain = 1
  case food = 2
}

extension Placemark {
  
  var placemarkType: PlacemarkType {
    get {
      if let placemarkType = PlacemarkType(rawValue: self.placemarkTypeValue) {
        return placemarkType
      }
      
      self.placemarkType = .myPlacemark
      return self.placemarkType
    }
    set {
      self.placemarkTypeValue = newValue.rawValue
    }
  }
}
