//
//  PrivacyNavigationDelegate.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 4/25/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

protocol PrivacyNavigationDelegate : class {}

extension PrivacyNavigationDelegate {
  
  func getPrivacyOnbardingController(modalControllerDelegate: ModalControllerDelegate?) -> PrivacyOnboardingViewController {
    return PrivacyOnboardingViewController.newViewController(modalControllerDelegate: modalControllerDelegate)
  }
}

extension PrivacyNavigationDelegate where Self : UIViewController {
  
  func presentPrivacyOnboarding(modalControllerDelegate: ModalControllerDelegate?, presentationMode: PresentationMode, options: [PresentableControllerOption] = []) {
    let viewController = PrivacyOnboardingViewController.newViewController(modalControllerDelegate: modalControllerDelegate)
    viewController.presentIn(self, withMode: presentationMode, options: options)
  }
  
  func presentPrivacy(presentationMode: PresentationMode, options: [PresentableControllerOption] = []) {
    let viewController = PrivacyViewController.newViewController()
    viewController.presentIn(self, withMode: presentationMode, options: options)
  }
}
