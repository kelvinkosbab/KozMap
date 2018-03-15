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
    self.dismissPresented { [weak self] in
      
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
    self.presentPopupAlert(title: title, message: message)
  }
  
  private func presentLocationUpdatedAlert(placemark: Placemark) {
    let title = "Location Updated"
    let message: String?
    if let name = placemark.name {
      message = "\(name) has been updated."
    } else {
      message = nil
    }
    self.presentPopupAlert(title: title, message: message)
  }
}
