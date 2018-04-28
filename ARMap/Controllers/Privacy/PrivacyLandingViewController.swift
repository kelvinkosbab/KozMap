//
//  PrivacyLandingViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 4/28/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class PrivacyLandingViewController : BaseViewController {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> PrivacyLandingViewController {
    return self.newViewController(fromStoryboardWithName: "Privacy")
  }
  
  static func newViewController(modalControllerDelegate: ModalControllerDelegate?) -> PrivacyLandingViewController {
    let viewController = self.newViewController()
    viewController.modalControllerDelegate = modalControllerDelegate
    return viewController
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var contentContainerView: UIView!
  
  weak var modalControllerDelegate: ModalControllerDelegate? = nil
}
