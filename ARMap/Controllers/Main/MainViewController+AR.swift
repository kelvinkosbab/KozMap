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
    self.present(viewController: configuringViewController, withMode: .visualEffectFade, options: [ .withoutNavigationController, .presentingViewControllerDelegate(self) ])
  }
  
  func hideConfiguringView() {
    
    guard let configuringViewController = self.configuringViewController else {
      self.showAllElements()
      self.enableAllElements()
      return
    }
    
    // Dismiss the controller
    configuringViewController.dismissController()
  }
}
