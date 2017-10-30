//
//  PermissionsViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit

class PermissionsViewController : UIViewController {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> PermissionsViewController {
    return self.newViewController(fromStoryboardWithName: "Main")
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var permissionsButton: UIButton!
  
  // MARK: - Lifecycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    LocationManager.shared.authorizationDelegate = self
  }
  
  // MARK: - Actions
  
  @IBAction func permissionsButtonSelected() {
    
    // Check if access has been denied - Settings
    guard LocationManager.shared.isAccessNotDetermined else {
      self.showSettingsAlert()
      return
    }
    
    // Request permissions
    LocationManager.shared.requestAuthorization()
  }
  
  private func showSettingsAlert() {
    let alertController = UIAlertController (title: "Action Required", message: "Go to Settings?", preferredStyle: .alert)
    
    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
      
      guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
        return
      }
      
      if UIApplication.shared.canOpenURL(settingsUrl) {
        UIApplication.shared.open(settingsUrl) { (success) in
          print("Settings opened: \(success)") // Prints true
        }
      }
    }
    alertController.addAction(settingsAction)
    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true, completion: nil)
  }
  
  func showMainController() {
    let mainViewController = MainViewController.newViewController()
    mainViewController.navigationItem.hidesBackButton = true
    RootNavigationController.shared.pushViewController(mainViewController, animated: true)
  }
}

extension PermissionsViewController : LocationManagerAuthorizationDelegate {
  
  func locationManagerDidUpdateAuthorization(_ locationManager: LocationManager) {
    
    if locationManager.isAccessAuthorized {
      self.showMainController()
    }
  }
}
