//
//  UIAlertController+Util.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/14/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

extension UIAlertController {
  
  func addDefaultOkAction(handler: (() -> Void)? = nil) {
    let action = UIAlertAction(title: LocalizedString.ok, style: .default) { _ in
      handler?()
    }
    self.addAction(action)
  }
  
  func addDefaultCancelAction(handler: (() -> Void)? = nil) {
    let action = UIAlertAction(title: LocalizedString.cancel, style: .cancel) { _ in
      handler?()
    }
    self.addAction(action)
  }
}
