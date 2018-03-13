//
//  SavedLocation+MyManagedObjectProtocol.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

extension Placemark : MyManagedObjectProtocol {
  
  // MARK: - MyManagedObjectProtocol
  
  static var sortDescriptors: [NSSortDescriptor] {
    return [ NSSortDescriptor(key: "lastDistance", ascending: true), NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "date", ascending: true) ]
  }
  
  // MARK: - Creating
  
  static func create(placemarkType: PlacemarkType, name: String, location: CLLocation, color: Color, distance: Double?, address: String?, phoneNumber: String? = nil, isFavorite: Bool = false, uuid: String = UUID().uuidString) -> Placemark {
    let object = self.create()
    object.uuid = uuid
    object.placemarkType = placemarkType
    object.update(name: name, location: location, color: color, distance: distance, address: address, phoneNumber: phoneNumber, isFavorite: isFavorite)
    return object
  }
  
  // MARK: - Fetch
  
  static func fetchMany(placemarkType: PlacemarkType, isFavorite: Bool) -> [Placemark] {
    let predicate = NSPredicate(format: "placemarkTypeValue == %d && isFavorite == %@", placemarkType.rawValue, NSNumber(value: isFavorite))
    return self.fetchMany(predicate: predicate)
  }
  
  // MARK: - Count
  
  static func countMany(placemarkType: PlacemarkType, isFavorite: Bool) -> Int {
    let predicate = NSPredicate(format: "placemarkTypeValue == %d && isFavorite == %@", placemarkType.rawValue, NSNumber(value: isFavorite))
    return self.fetchMany(predicate: predicate).count
  }
  
  // MARK: - Delete
  
  static func deleteMany(placemarkType: PlacemarkType, isFavorite: Bool) {
    let predicate = NSPredicate(format: "placemarkTypeValue == %d && isFavorite == %@", placemarkType.rawValue, NSNumber(value: isFavorite))
    self.deleteMany(predicate: predicate)
  }
  
  // MARK: - NSFetechedResultsController
  
  static func newFetchedResultsController(uuid: String) -> NSFetchedResultsController<Placemark> {
    let predicate = NSPredicate(format: "uuid == %@", uuid)
    return self.newFetchedResultsController(predicate: predicate)
  }
  
  static func newFetchedResultsController(placemark: Placemark) -> NSFetchedResultsController<Placemark> {
    let predicate = NSPredicate(format: "SELF == %@", placemark)
    return self.newFetchedResultsController(predicate: predicate)
  }
  
  static func newFetchedResultsController(placemarkType: PlacemarkType) -> NSFetchedResultsController<Placemark> {
    let predicate = NSPredicate(format: "placemarkTypeValue == %d", placemarkType.rawValue)
    return self.newFetchedResultsController(predicate: predicate)
  }
  
  static func newFetchedResultsController(placemarkType: PlacemarkType, isFavorite: Bool) -> NSFetchedResultsController<Placemark> {
    let predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: isFavorite))
    return self.newFetchedResultsController(predicate: predicate)
  }
}
