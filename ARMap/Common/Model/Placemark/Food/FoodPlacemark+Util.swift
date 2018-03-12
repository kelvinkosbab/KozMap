//
//  FoodPlacemark+Util.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/9/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import Foundation
import CoreLocation

extension FoodPlacemark {
  
  // MARK: - Create
  
  static func create(name: String, location: CLLocation, distance: Double?, address: String?, phoneNumber: String?, isFavorite: Bool = false, uuid: String = UUID().uuidString) -> FoodPlacemark {
    let object = self.create()
    object.isFavorite = isFavorite
    object.uuid = uuid
    object.placemarkType = .food
    object.address = address
    let color = Color.red
    object.update(name: name, location: location, color: color, distance: distance, phoneNumber: phoneNumber)
    return object
  }
  
  // MARK: - Fetch
  
  static func fetchMany(isFavorite: Bool) -> [FoodPlacemark] {
    let predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: isFavorite))
    return self.fetchMany(predicate: predicate)
  }
  
  // MARK: - Delete
  
  static func deleteMany(isFavorite: Bool) {
    let predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: isFavorite))
    self.deleteMany(predicate: predicate)
  }
}
