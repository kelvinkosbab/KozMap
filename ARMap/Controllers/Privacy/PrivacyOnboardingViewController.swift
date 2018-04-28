//
//  PrivacyOnboardingViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 4/25/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class PrivacyOnboardingViewController : BaseViewController {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> PrivacyOnboardingViewController {
    return self.newViewController(fromStoryboardWithName: "Privacy")
  }
  
  static func newViewController(modalControllerDelegate: ModalControllerDelegate?) -> PrivacyOnboardingViewController {
    let viewController = self.newViewController()
    viewController.modalControllerDelegate = modalControllerDelegate
    return viewController
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var acceptButton: UIButton!
  @IBOutlet weak var otherOptionsButton: UIButton!
  
  weak var modalControllerDelegate: ModalControllerDelegate? = nil
  
  // MARK: - Actions
  
  @IBAction func acceptButtonSelected() {
    
  }
  
  @IBAction func otherOptionsButtonSelected() {
    
  }
}
