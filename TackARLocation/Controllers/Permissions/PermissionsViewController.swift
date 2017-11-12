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
  
  @IBOutlet weak var locationPermissionButton: UIButton!
  @IBOutlet weak var cameraPermissionButton: UIButton!
  
  // MARK: - Lifecycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    LocationManager.shared.authorizationDelegate = self
    CameraPermissionManager.shared.authorizationDelegate = self
  }
  
  // MARK: - Content
  
  func reloadContent() {
    
    // Location
    if LocationManager.shared.isAccessAuthorized {
      self.locationPermissionButton.setTitle("Location Access Granted", for: .normal)
      self.locationPermissionButton.isUserInteractionEnabled = false
      self.locationPermissionButton.setTitleColor(.lightGray, for: .normal)
    } else {
      self.locationPermissionButton.setTitle("Allow Location Access", for: .normal)
      self.locationPermissionButton.isUserInteractionEnabled = true
      self.locationPermissionButton.setTitleColor(.blue, for: .normal)
    }
    
    // Camera
    if CameraPermissionManager.shared.isAccessAuthorized {
      self.cameraPermissionButton.setTitle("Camera Access Granted", for: .normal)
      self.cameraPermissionButton.isUserInteractionEnabled = false
      self.cameraPermissionButton.setTitleColor(.lightGray, for: .normal)
    } else {
      self.cameraPermissionButton.setTitle("Allow Location Access", for: .normal)
      self.cameraPermissionButton.isUserInteractionEnabled = true
      self.cameraPermissionButton.setTitleColor(.blue, for: .normal)
    }
  }
  
  // MARK: - Actions
  
  @IBAction func locationPermissionButtonSelected() {
    
    // Check if access has been denied - Settings
    guard LocationManager.shared.isAccessNotDetermined else {
      self.showSettingsAlert()
      return
    }
    
    // Request permissions
    LocationManager.shared.requestAuthorization()
  }
  
  @IBAction func cameraPermissionButtonSelected() {
    
    // Check if access has been denied - Settings
    guard CameraPermissionManager.shared.isAccessNotDetermined else {
      self.showSettingsAlert()
      return
    }
    
    // Request permissions
    CameraPermissionManager.shared.requestAuthorization()
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

// MARK: - LocationManagerAuthorizationDelegate

extension PermissionsViewController : LocationManagerAuthorizationDelegate {
  
  func locationManagerDidUpdateAuthorization() {
    
    if PermissionManager.shared.isAccessAuthorized {
//      self.showMainController()
    }
  }
}

// MARK: - CameraPermissionDelegate

extension PermissionsViewController : CameraPermissionDelegate {
  
  func cameraPermissionManagerDidUpdateAuthorization() {
    
    if PermissionManager.shared.isAccessAuthorized {
//      self.showMainController()
    }
  }
}
