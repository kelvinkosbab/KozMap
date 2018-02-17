//
//  ARState.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/20/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import Foundation

protocol ARStateDelegate : class {
  func arStateDidUpdate(_ state: ARState)
}

enum ARState {
  case configuring, normal, limited(Reason), notAvailable, unsupported
  
  enum Reason {
    case insufficientFeatures, excessiveMotion, initializing, relocalizing
  }
  
  var status: String? {
    switch self {
    case .configuring:
      return "Configuring"
    case .limited(.insufficientFeatures):
      return "Insufficent Features"
    case .limited(.excessiveMotion):
      return "Excessive Motion"
    case .limited(.initializing):
      return "Initializing"
    case .limited(.relocalizing):
      return "Relocalizing"
    case .notAvailable:
      return "Not Available"
    case .unsupported:
      return "Unsupported Device"
    case .normal:
      return nil
    }
  }
  
  var message: String? {
    switch self {
    case .limited(.insufficientFeatures):
      return "Please move to a well lit area with defined surface features."
    case .limited(.excessiveMotion):
      return "Please hold the device steady pointing horizontally."
    case .limited(.initializing), .limited(.relocalizing):
      return "Please hold the device steady pointing horizontally in a well lit area."
    case .notAvailable, .unsupported:
      return "Only supported on Apple devices with an A9, A10, or A11 chip or newer. This includes all phones including the iPhone 6s/6s+ and newer as well as all iPad Pro models and the 2017 iPad."
    case .normal, .configuring:
      return nil
    }
  }
}
