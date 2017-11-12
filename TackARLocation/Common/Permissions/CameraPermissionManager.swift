//
//  CameraPermissionManager.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/11/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import AVFoundation

protocol CameraPermissionDelegate : class {
  func cameraPermissionManagerDidUpdateAuthorization()
}

class CameraPermissionManager : NSObject, PermissionManagerDelegate {
  
  // MARK: - Singleton
  
  static let shared = CameraPermissionManager()
  
  private override init() { super.init() }
  
  // MARK: - Properties
  
  weak var authorizationDelegate: CameraPermissionDelegate? = nil
  
  // MARK: - PermissionManagerDelegate
  
  var status: PermissionAuthorizationStatus {
    switch self.avAuthorizationStatus {
    case .authorized:
      return .authorized
    case .denied, .restricted:
      return .denied
    case .notDetermined:
      return .notDetermined
    }
  }
  
  private var avAuthorizationStatus: AVAuthorizationStatus {
    return AVCaptureDevice.authorizationStatus(for: .video)
  }
  
  var isAccessAuthorized: Bool {
    return self.avAuthorizationStatus == .authorized
  }
  
  var isAccessDenied: Bool {
    switch self.avAuthorizationStatus {
    case .denied, .restricted:
      return true
    default:
      return false
    }
  }
  
  var isAccessNotDetermined: Bool {
    return self.avAuthorizationStatus == .notDetermined
  }
  
  // MARK: - Authorization
  
  func requestAuthorization() {
    AVCaptureDevice.requestAccess(for: .video) { granted in
      self.authorizationDelegate?.cameraPermissionManagerDidUpdateAuthorization()
      if granted {
        Log.log("Authorization granted")
      } else {
        Log.log("Authorization denied")
      }
    }
  }
}
