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
    if let locationDetailViewController = self.presentedViewController as? LocationDetailViewController, locationDetailViewController.isCreatingSavedLocation {
      locationDetailViewController.location = location
    } else if let locationListViewController = self.presentedViewController as? LocationListViewController {
      locationListViewController.currentLocation = location
    }
  }
  
  func locationManagerDidUpdateHeading(_ locationManager: LocationManager, heading: CLLocationDirection, accuracy: CLLocationDirection) {}
}

extension MainViewController : LocationDetailViewControllerDelegate {
  
  func didUpdate(savedLocation: SavedLocation) {
    let dispatchGroup = DispatchGroup()
    if let _ = self.presentedViewController as? LocationDetailViewController {
      dispatchGroup.enter()
      self.dismiss(animated: true) {
        dispatchGroup.leave()
      }
    }
    
    dispatchGroup.notify(queue: .main) { [weak self] in
      
      // Present an alert
      self?.presentLocationUpdatedAlert(savedLocation: savedLocation)
    }
  }
  
  func didSave(savedLocation: SavedLocation) {
    let dispatchGroup = DispatchGroup()
    if let _ = self.presentedViewController as? LocationDetailViewController {
      dispatchGroup.enter()
      self.dismiss(animated: true) {
        dispatchGroup.leave()
      }
    }
    
    dispatchGroup.notify(queue: .main) { [weak self] in
      
      // Present an alert
      self?.presentLocationSavedAlert(savedLocation: savedLocation)
    }
  }
  
  private func presentLocationSavedAlert(savedLocation: SavedLocation) {
    let title = "Location Saved"
    let message: String?
    if let name = savedLocation.name {
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
  
  private func presentLocationUpdatedAlert(savedLocation: SavedLocation) {
    let title = "Location Updated"
    let message: String?
    if let name = savedLocation.name {
      message = "\(name) has been updated."
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
  
  func shouldEdit(savedLocation: SavedLocation) {
    self.dismiss(animated: true) { [weak self] in
      self?.presentLocationDetail(savedLocation: savedLocation)
    }
  }
  
  func shouldDelete(savedLocation: SavedLocation) {
    
    // Delete this location from core data
    SavedLocation.deleteOne(savedLocation)
  }
}
