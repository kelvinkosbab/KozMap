//
//  MainViewController+AR.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/20/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

// MARK: - ARViewControllerDelegate

extension MainViewController : ARViewControllerDelegate {
  
  func userDidTap(placemark: Placemark) {
    self.presentLocationDetail(placemark: placemark)
  }
}

// MARK: - ARStateDelegate

extension MainViewController : ARStateDelegate {
  
  // MARK: - ARStateDelegate
  
  func arStateDidUpdate(_ state: ARState) {
    
    // Check if the scene hasn't already been configured
    guard self.arViewController?.sceneNode == nil else {
      // TODO: - KAK future - display any necessary state messages
      return
    }
    
    switch state {
    case .normal:
      self.hideConfiguringView()
    default:
      self.showConfiguringView(state: state)
    }
  }
  
  // MARK: - Configuring Messages
  
  func showConfiguringView(state: ARState) {
    
    // Check if already showing the configuring view
    if let configuringViewController = self.configuringViewController {
      configuringViewController.state = .statusMessage(state.status, state.message)
      return
    }
    
    // Create the configuring view
    let configuringViewController = ConfiguringViewController.newViewController(state: .statusMessage(state.status, state.message))
    self.configuringViewController = configuringViewController
    self.present(viewController: configuringViewController, withMode: .visualEffectFade, options: [ .withoutNavigationController ])
  }
  
  func hideConfiguringView() {
    
    guard let configuringViewController = self.configuringViewController else {
      self.showAllElements()
      self.enableAllElements()
      return
    }
    
    // Dismiss the controller
    configuringViewController.dismissController { [weak self] in
      self?.configuringViewController = nil
      self?.enableAllElements()
    }
  }
  
  // MARK: - Showing and Enabling Views
  
  func showAllElements() {
    self.aboveSafeAreaVisualEffectView.effect = UIBlurEffect(style: .dark)
    self.listVisualEffectView.effect = UIBlurEffect(style: .light)
    self.listButton.alpha = 1
    self.addVisualEffectView.effect = UIBlurEffect(style: .light)
    self.addButton.alpha = 1
  }
  
  func enableAllElements() {
    self.listButton.isUserInteractionEnabled = true
    self.addButton.isUserInteractionEnabled = true
    self.loadConfiguredNavigationBar()
  }
  
  func disableAllElements() {
    self.clearNavigationBar()
    self.listButton.isUserInteractionEnabled = false
    self.addButton.isUserInteractionEnabled = false
  }
  
  func hideAllElements() {
    self.aboveSafeAreaVisualEffectView.effect = nil
    self.listVisualEffectView.effect = nil
    self.listButton.alpha = 0
    self.addVisualEffectView.effect = nil
    self.addButton.alpha = 0
  }
}

// MARK: - PresentingViewControllerDelegate

extension MainViewController : PresentingViewControllerDelegate {
  
  func willPresentViewController(_ viewController: UIViewController) {
    let contentViewController = (viewController as? UINavigationController)?.viewControllers.first ?? viewController
    
    // Disable and hide navigation elements when presenting configuring view
    if let _ = contentViewController as? ConfiguringViewController {
      self.disableAllElements()
    }
  }
  
  func isPresentingViewController(_ viewController: UIViewController?) {
    let contentViewController = (viewController as? UINavigationController)?.viewControllers.first ?? viewController
    
    // Hide elements when prsenting configuring view
    if let _ = contentViewController as? ConfiguringViewController {
      self.hideAllElements()
    }
  }
  
  func didPresentViewController(_ viewController: UIViewController?) {}
  
  func willDismissViewController(_ viewController: UIViewController) {}
  
  func isDismissingViewController(_ viewController: UIViewController?) {
    let contentViewController = (viewController as? UINavigationController)?.viewControllers.first ?? viewController
    
    // Show elements when prsenting configuring view
    if let _ = contentViewController as? ConfiguringViewController {
      self.showAllElements()
    }
  }
}
