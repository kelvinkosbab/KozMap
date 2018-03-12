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
  
  static func create(name: String, location: CLLocation, color: Color, distance: Double?, phoneNumber: String? = nil, placemarkType: PlacemarkType = .myPlacemark, uuid: String = UUID().uuidString) -> Placemark {
    let object = self.create()
    object.uuid = uuid
    object.placemarkType = placemarkType
    object.update(name: name, location: location, color: color, distance: distance, phoneNumber: phoneNumber)
    return object
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
    let predicate = NSPredicate(format: "placemarkTypeValue == %d", PlacemarkType.myPlacemark.rawValue)
    return self.newFetchedResultsController(predicate: predicate)
  }
}
