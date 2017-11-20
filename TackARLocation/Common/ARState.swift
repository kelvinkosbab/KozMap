//
//  ARState.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/20/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation

enum ARState {
  case configuring, normal, limited(Reason), notAvailable
  
  enum Reason {
    case insufficientFeatures, excessiveMotion, initializing
  }
}

protocol ARStateDelegate : class {
  func arStateDidUpdate(_ state: ARState)
}
