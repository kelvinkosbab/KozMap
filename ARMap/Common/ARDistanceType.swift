//
//  ARDistanceType.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 1/10/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import Foundation

enum ARDistanceType {
  
  init(distance: Double) {
    switch distance {
    case ..<ARDistanceType.close.cutoff:
      self = .close
    case ARDistanceType.close.cutoff..<ARDistanceType.medium.cutoff:
      self = .medium
    default:
      self = .far
    }
  }
  
  case close
  case medium
  case far
  
  var cutoff: Double {
    switch self {
    case .close:
      return 400 // 400 meters = 0.25 miles
    case .medium:
      return 8000 // 8000 meters = 5 miles
    case .far:
      return Double.greatestFiniteMagnitude
    }
  }
}
