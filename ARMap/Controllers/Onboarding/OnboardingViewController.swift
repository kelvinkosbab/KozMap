//
//  OnboardingViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 4/30/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class OnboardingViewController : BaseViewController {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> OnboardingViewController {
    return self.newViewController(fromStoryboardWithName: "Onboarding")
  }
  
  static func newViewController(modalControllerDelegate: ModalControllerDelegate?) -> OnboardingViewController {
    let viewController = self.newViewController()
    viewController.modalControllerDelegate = modalControllerDelegate
    return viewController
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var nextButton: UIButton!
  
  weak var modalControllerDelegate: ModalControllerDelegate? = nil
  
  var defaults: Defaults {
    return Defaults.shared
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.isNavigationBarHidden = true
    self.navigationItem.largeTitleDisplayMode = .never
  }
  
  // MARK: - Actions
  
  @IBAction func nextButtonSelected() {
    // Onboarding flag
    self.defaults.hasOnboarded = true
    
    // Signal the modal delegate
    self.modalControllerDelegate?.dismissModalController(self)
  }
}
