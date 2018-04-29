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
  
  var defaults: Defaults {
    return Defaults.shared
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.largeTitleDisplayMode = .never
  }
  
  // MARK: - Actions
  
  @IBAction func acceptButtonSelected() {
    self.shareAndDismiss()
  }
  
  @IBAction func otherOptionsButtonSelected() {
    self.presentOtherOptionsAlert()
  }
  
  func presentOtherOptionsAlert() {
    let alertController = UIAlertController(title: "App Analytics", message: "Help app developers improve their apps by allowing Kozing to share crash data as well as statics about how you use their apps with them.", preferredStyle: .alert)
    
    // Share
    let shareAction = UIAlertAction(title: "Share with App Developers", style: .default) { [weak self] _ in
      self?.shareAndDismiss()
    }
    alertController.addAction(shareAction)
    
    // Don't share
    let dontShareAction = UIAlertAction(title: "Don't Share", style: .destructive) { [weak self] _ in
      self?.shareAndDismiss()
    }
    alertController.addAction(dontShareAction)
    
    // Cancel
    alertController.addDefaultCancelAction()
    
    // Present the controller
    self.present(alertController, animated: true, completion: nil)
  }
  
  func shareAndDismiss() {
    
    // Enable analytics
    AnalyticsManager.shared.setAnalyticsCollectionEnabled(true)
    
    // Privacy onboarding flag
    self.defaults.hasOnboardedPrivacy = true
    
    // Signal the modal delegate
    self.modalControllerDelegate?.dismissModalController(self)
  }
  
  func dontShareAndDismiss() {
    
    // Disable analytics
    AnalyticsManager.shared.setAnalyticsCollectionEnabled(false)
    
    // Privacy onboarding flag
    self.defaults.hasOnboardedPrivacy = true
    
    // Signal the modal delegate
    self.modalControllerDelegate?.dismissModalController(self)
  }
}
