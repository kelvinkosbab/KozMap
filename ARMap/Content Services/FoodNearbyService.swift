//
//  FoodNearbyService.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/11/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class FoodNearbyService : NSObject {
  
  // MARK: - Singleton
  
  static let shared = FoodNearbyService()
  
  private override init() {
    super.init()
  }
  
  // MARK: - Configure
  
  func configure() {
    self.currentSearchText = self.defaults.defaultFoodSearchText
  }
  
  // MARK: - Properties
  
  var locationManager: LocationManager {
    return LocationManager.shared
  }
  
  var currentLocation: CLLocation? {
    return self.locationManager.currentLocation
  }
  
  let locationSearchService = LocationSearchService()
  var currentSearchText: String? = nil {
    didSet {
      if self.currentSearchText != oldValue {
        self.updateFoodPlacemarks(searchText: self.currentSearchText)
        
        // Update defaults if it has not been updated
        if Defaults.shared.lastFoodSearchText != self.currentSearchText {
          Defaults.shared.lastFoodSearchText = self.currentSearchText
        }
      }
    }
  }
  
  var defaultFoodSearchText: String {
    return self.defaults.defaultFoodSearchText
  }
  
  var displaySearchText: String? {
    return self.currentSearchText == self.defaultFoodSearchText ? "" : self.currentSearchText
  }
  
  // MARK: - Defaults
  
  internal var defaults: Defaults {
    return self.defaultsFetchedResultsController.fetchedObjects?.first ?? Defaults.shared
  }
  
  private lazy var defaultsFetchedResultsController: NSFetchedResultsController<Defaults> = {
    let controller = Defaults.newFetchedResultsController()
    controller.delegate = self
    try? controller.performFetch()
    return controller
  }()
  
  // MARK: - Food Placemarks
  
  private func updateFoodPlacemarks(searchText: String?) {
    
    // Delete all the current non-favorite food placemarks
    Placemark.deleteMany(placemarkType: .food, isFavorite: false)
    MyDataManager.shared.saveMainContext()
    
    // Check for presence of search text
    guard let searchText = searchText?.trimmed, searchText.count > 0 else {
      return
    }
    
    // Check for current location
    guard let currentLocation = self.currentLocation else {
      return
    }
    
    // Query for food nearby
    Log.log("Querying \(searchText)")
    self.locationSearchService.queryLocations(query: searchText, currentLocation: currentLocation, coordinateSpan: .xs) { [weak self] mapItems in
      
      // Check if the results match the current value search text in cases where it has changed
      guard let currentSearchText = self?.currentSearchText, searchText == currentSearchText else {
        Log.log("Text updated, abort this cycle")
        return
      }
      
      // Create the food placemarks from the discovered map items
      Log.log("Processing \(mapItems.count) query resutls")
      for mapItem in mapItems {
        
        guard let name = mapItem.name, let location = mapItem.placemark.location else {
          Log.log("Failed to fetch name and/or location from map Item")
          continue
        }
        
        // Create the food placemark
        _ = Placemark.create(placemarkType: .food, name: name, location: location, color: Color.red, distance: mapItem.distance, address: mapItem.address, phoneNumber: mapItem.phoneNumber, isFavorite: false)
      }
      MyDataManager.shared.saveMainContext()
    }
  }
}

// MARK: - NSFetchedResultsControllerDelegate

extension FoodNearbyService : NSFetchedResultsControllerDelegate {
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    
    guard controller == self.defaultsFetchedResultsController else {
      return
    }
    
    // Update the search text
    if self.currentSearchText != self.defaults.lastFoodSearchText {
      self.currentSearchText = self.defaults.lastFoodSearchText
    }
  }
}
