//
//  MainViewController+CoreLocation.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit
import CoreLocation

// MARK: - AddLocationViewControllerDelegate

extension MainViewController : AddLocationViewControllerDelegate {
  
  func didSave(placemark: Placemark) {
    let dispatchGroup = DispatchGroup()
    if let _ = self.presentedViewController {
      dispatchGroup.enter()
      self.dismiss(animated: true) {
        dispatchGroup.leave()
      }
    }
    
    dispatchGroup.notify(queue: .main) { [weak self] in
      
      // Present an alert
      self?.presentLocationSavedAlert(placemark: placemark)
    }
  }
  
  private func presentLocationSavedAlert(placemark: Placemark) {
    let title = "Placemark Saved"
    let message: String?
    if let name = placemark.name {
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
  
  private func presentLocationUpdatedAlert(placemark: Placemark) {
    let title = "Location Updated"
    let message: String?
    if let name = placemark.name {
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

// MARK: - LocationListViewControllerDelegate

extension MainViewController : LocationListViewControllerDelegate {
  
  func shouldEdit(placemark: Placemark) {
    self.dismiss(animated: true) { [weak self] in
      self?.presentLocationDetail(placemark: placemark)
    }
  }
  
  func shouldTransitionToAddPlacemark() {
    self.dismiss(animated: true) { [weak self] in
      self?.presentAddLocation()
    }
  }
}

// MARK: - SearchViewControllerDelegate

extension MainViewController : SearchViewControllerDelegate {
  
  func shouldAdd(mapItem: MapItem) {
    self.dismiss(animated: true) { [weak self] in
      self?.presentAddLocation(mapItem: mapItem)
    }
  }
}
