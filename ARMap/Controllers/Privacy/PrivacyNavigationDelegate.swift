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
    let modeChooserViewController = PrivacyOnboardingViewController.newViewController(modalControllerDelegate: modalControllerDelegate)
    modeChooserViewController.presentIn(self, withMode: presentationMode, options: options)
  }
  
  func presentPrivacy(presentationMode: PresentationMode, options: [PresentableControllerOption] = []) {
    let modeChooserViewController = PrivacyViewController.newViewController()
    modeChooserViewController.presentIn(self, withMode: presentationMode, options: options)
  }
}
