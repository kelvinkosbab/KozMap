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
  
  var isLocationAuthorized: Bool {
    return LocationManager.shared.isAccessAuthorized
  }
  
  var isLocationNotDetermined: Bool {
    return LocationManager.shared.isAccessNotDetermined
  }
  
  var isCameraAuthorized: Bool = CameraPermissionManager.shared.isAccessAuthorized
  var isCameraNotDetermined: Bool = CameraPermissionManager.shared.isAccessNotDetermined
  
  var areAllPermissionAuthorized: Bool {
    return self.isLocationAuthorized && self.isCameraAuthorized
  }
  
  // MARK: - Lifecycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    LocationManager.shared.authorizationDelegate = self
    CameraPermissionManager.shared.authorizationDelegate = self
    self.isCameraAuthorized = CameraPermissionManager.shared.isAccessAuthorized
    self.isCameraNotDetermined = CameraPermissionManager.shared.isAccessNotDetermined
    self.reloadContent()
  }
  
  // MARK: - Content
  
  func reloadContent() {
    
    // Location
    if self.isLocationAuthorized {
      self.locationPermissionButton.setTitle("Location Access Granted", for: .normal)
      self.locationPermissionButton.isUserInteractionEnabled = false
      self.locationPermissionButton.setTitleColor(.lightGray, for: .normal)
    } else {
      self.locationPermissionButton.setTitle("Allow Location Access", for: .normal)
      self.locationPermissionButton.isUserInteractionEnabled = true
      self.locationPermissionButton.setTitleColor(.cyan, for: .normal)
    }
    
    // Camera
    if self.isCameraAuthorized {
      self.cameraPermissionButton.setTitle("Camera Access Granted", for: .normal)
      self.cameraPermissionButton.isUserInteractionEnabled = false
      self.cameraPermissionButton.setTitleColor(.lightGray, for: .normal)
    } else {
      self.cameraPermissionButton.setTitle("Allow Camera Access", for: .normal)
      self.cameraPermissionButton.isUserInteractionEnabled = true
      self.cameraPermissionButton.setTitleColor(.cyan, for: .normal)
    }
  }
  
  // MARK: - Actions
  
  @IBAction func locationPermissionButtonSelected() {
    
    // Check if access has been denied - Settings
    guard self.isLocationNotDetermined else {
      self.showSettingsAlert()
      return
    }
    
    // Request permissions
    LocationManager.shared.requestAuthorization()
  }
  
  @IBAction func cameraPermissionButtonSelected() {
    
    // Check if access has been denied - Settings
    guard self.isCameraNotDetermined else {
      self.showSettingsAlert()
      return
    }
    
    // Request permissions
    CameraPermissionManager.shared.requestAuthorization()
  }
  
  private func showSettingsAlert() {
    let alertController = UIAlertController (title: "Action Required", message: "Go to Settings?", preferredStyle: .alert)
    
    let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ -> Void in
      
      guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
        return
      }
      
      if UIApplication.shared.canOpenURL(settingsUrl) {
        UIApplication.shared.open(settingsUrl)
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
    
    if self.areAllPermissionAuthorized {
      self.showMainController()
    }
    
    // Update the content
    self.reloadContent()
  }
}

// MARK: - CameraPermissionDelegate

extension PermissionsViewController : CameraPermissionDelegate {
  
  func cameraPermissionManagerDidUpdateAuthorization(isAuthorized: Bool) {
    self.isCameraAuthorized = isAuthorized
    if self.areAllPermissionAuthorized {
      self.showMainController()
    }
    
    // Update the content
    self.reloadContent()
  }
}
