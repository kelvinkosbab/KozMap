//
//  MainViewController+CoreLocation.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit
import CoreLocation

extension MainViewController : LocationManagerDelegate {
  
  func locationManagerDidUpdateLocation(_ locationManager: LocationManager, location: CLLocation) {
    
    // Update location on child AR controller
    self.arViewController?.currentLocation = location
    
    // Update location on presented controllers
    if let addLocationViewController = self.presentedViewController as? AddLocationViewController {
      addLocationViewController.location = location
    } else if let locationListViewController = self.presentedViewController as? LocationListViewController {
      locationListViewController.currentLocation = location
    }
  }
  
  func locationManagerDidUpdateHeading(_ locationManager: LocationManager, heading: CLLocationDirection, accuracy: CLLocationDirection) {}
}

extension MainViewController : AddLocationViewControllerDelegate {
  
  func didSave(savedLocation: SavedLocation) {
    
    let dispatchGroup = DispatchGroup()
    if let _ = self.presentedViewController as? AddLocationViewController {
      dispatchGroup.enter()
      self.dismiss(animated: true) {
        dispatchGroup.leave()
      }
    }
    
    dispatchGroup.notify(queue: .main) { [weak self] in
      
      // Add this location to the scene
      self?.arViewController?.add(savedLocation: savedLocation)
      
      // Present an alert
      self?.presentLocationSavedAlert(location: savedLocation)
    }
  }
  
  private func presentLocationSavedAlert(location: SavedLocation) {
    let title = "Location Saved"
    let message: String?
    if let name = location.name {
      message = "\(name) has been saved."
    } else {
      message = nil
    }
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    self.present(alertController, animated: true) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      }
    }
  }
}

extension MainViewController : LocationListViewControllerDelegate {
  
  func shouldDelete(savedLocation: SavedLocation) {
    
    // Remove this location from the scene view
    self.arViewController?.remove(savedLocation: savedLocation)
    
    // Delete this location from core data
    SavedLocation.deleteOne(savedLocation)
  }
}
