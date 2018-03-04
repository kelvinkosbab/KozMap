//
//  PlacemarkAPIDelegate.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/3/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

protocol PlacemarkAPIDelegate : class {}
extension PlacemarkAPIDelegate {
  
  func deletePlacemark(_ placemark: Placemark) {
    
    // Delete this location from core data
    Placemark.deleteOne(placemark)
  }
}

extension PlacemarkAPIDelegate where Self : UIViewController {
  
  func promptDeletePlacemark(placemark: Placemark, didDeleteHandler: (() -> Void)? = nil) {
    
    let alertController = UIAlertController(title: "Delete \(placemark.name ?? "Placemark")?", message: nil, preferredStyle: .alert)
    
    // Delete
    let deleteAction = UIAlertAction(title: "Delete Placemark", style: .destructive) { [weak self] _ in
      
      // Delete the placemark
      self?.deletePlacemark(placemark)
      
      // Completion
      didDeleteHandler?()
    }
    alertController.addAction(deleteAction)
    
    // Cancel
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    // Present the alert
    self.present(alertController, animated: true, completion: nil)
  }
}
