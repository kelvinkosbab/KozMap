//
//  UIViewController+Alert.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/10/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

extension UIViewController {
  
  func presentPopupAlert(title: String?, message: String?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    self.present(alertController, animated: true) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      }
    }
  }
}
