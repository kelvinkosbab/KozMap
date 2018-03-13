//
//  CurrentLocationUpdatableService.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/19/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationUpdatableService : NSObject, NSFetchedResultsControllerDelegate {
  
  // MARK: - Singleton
  
  static let shared = CurrentLocationUpdatableService()
  
  private override init() { super.init() }
  
  deinit {
    self.stopListening()
  }
  
  // MARK: - Properties
  
  private var isListening: Bool = false
  
  // MARK: - NSFetchedResultsControllerDelegate
  
  private var placemarks: [Placemark] {
    return self.myPlacemarksFetchedResultsController?.fetchedObjects ?? []
  }
  
  private lazy var myPlacemarksFetchedResultsController: NSFetchedResultsController<Placemark>? = {
    let controller = Placemark.newFetchedResultsController()
    controller.delegate = self
    try? controller.performFetch()
    return controller
  }()
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {}
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert: break
    case .delete: break
    case .update: break
    case .move: break
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {}
  
  // MARK: - Listening for Updates
  
  func startListening() {
    
    guard !self.isListening else {
      return
    }
    
    // Start listening
    self.isListening = true
    NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveUpdatedLocationNotification(_:)), name: .locationManagerDidUpdateCurrentLocation, object: nil)
  }
  
  func stopListening() {
    NotificationCenter.default.removeObserver(self, name: .locationManagerDidUpdateCurrentLocation, object: nil)
    self.isListening = false
  }
  
  // MARK: - Notifications
  
  @objc private func didReceiveUpdatedLocationNotification(_ notification: Notification) {
    if let currentLocation = LocationManager.shared.currentLocation {
      self.updateSavedLocationDistances(currentLocation: currentLocation)
    }
  }
  
  // MARK: - Updating the model
  
  private func updateSavedLocationDistances(currentLocation: CLLocation) {
    
    // Update all placemarks
    for placemark in self.placemarks {
      self.updateLastDistance(placemark: placemark, currentLocation: currentLocation)
    }
    MyDataManager.shared.saveMainContext()
  }
  
  private func updateLastDistance(placemark: Placemark, currentLocation: CLLocation) {
    let updatedDistance = placemark.location.distance(from: currentLocation)
    if placemark.lastDistance != updatedDistance {
      placemark.lastDistance = updatedDistance
    }
  }
}
