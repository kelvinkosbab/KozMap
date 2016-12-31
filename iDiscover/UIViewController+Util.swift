//
//  UIViewController+Util.swift
//  Test
//
//  Created by Kelvin Kosbab on 12/26/16.
//  Copyright © 2016 Kozinga. All rights reserved.
//

import Foundation
import UIKit

enum MyStoryboard {
  case main, settings
  
  private var name: String {
    switch self {
    case .main:
      return "Main"
    case .settings:
      return "Settings"
    }
  }
  
  var storyboard: UIStoryboard {
    return UIStoryboard(name: self.name, bundle: nil)
  }
}

extension UIViewController {
  
  static func newController(fromStoryboard storyboard: MyStoryboard, withIdentifier identifier: String) -> UIViewController {
    return storyboard.storyboard.instantiateViewController(withIdentifier: identifier)
  }
}