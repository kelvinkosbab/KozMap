//
//  InteractiveTransitionMode.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 2/19/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

enum InteractiveTransitionMode {
  case percent(CGFloat?), velocity(CGFloat?)
  
  static let defaultPercentThreshold: CGFloat = 0.3
  static let defaultVelocityThreshold: CGFloat = 850
}

extension Sequence where Iterator.Element == InteractiveTransitionMode {
  
  var percentThreshold: CGFloat? {
    for option in self {
      switch option {
      case .percent(let threshold):
        if let threshold = threshold {
          return threshold
        }
      default: break
      }
    }
    return InteractiveTransitionMode.defaultPercentThreshold
  }
  
  var velocityThreshold: CGFloat? {
    for option in self {
      switch option {
      case .velocity(let threshold):
        if let threshold = threshold {
          return threshold
        }
      default: break
      }
    }
    return InteractiveTransitionMode.defaultVelocityThreshold
  }
}
