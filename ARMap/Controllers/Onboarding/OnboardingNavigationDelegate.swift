//
//  OnboardingNavigationDelegate.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 4/30/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

protocol OnboardingNavigationDelegate : class {}

extension OnboardingNavigationDelegate {
  
  func getOnbardingController(modalControllerDelegate: ModalControllerDelegate?) -> OnboardingViewController {
    return OnboardingViewController.newViewController(modalControllerDelegate: modalControllerDelegate)
  }
}

extension OnboardingNavigationDelegate where Self : UIViewController {
  
  func presentOnboarding(modalControllerDelegate: ModalControllerDelegate?, presentationMode: PresentationMode, options: [PresentableControllerOption] = []) {
    let viewController = OnboardingViewController.newViewController(modalControllerDelegate: modalControllerDelegate)
    viewController.presentIn(self, withMode: presentationMode, options: options)
  }
}
