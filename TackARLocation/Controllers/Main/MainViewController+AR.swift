//
//  MainViewController+AR.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/20/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit

extension MainViewController : ARStateDelegate {
  
  // MARK: - ARStateDelegate
  
  func arStateDidUpdate(_ state: ARState) {
    
    // Check if the scene hasn't already been configured
    guard self.arViewController?.sceneNode == nil else {
      // TODO: - KAK future - display any state messages
      return
    }
    
    switch state {
    case .configuring:
      self.showConfiguringView(status: "Configuring", message: nil)
    case .limited(.insufficientFeatures):
      self.showConfiguringView(status: "Insufficent Features", message: "Please move to a well lit area with defined surface features.")
    case .limited(.excessiveMotion):
      self.showConfiguringView(status: "Excessive Motion", message: "Please hold the device steady pointing horizontally.")
    case .limited(.initializing):
      self.showConfiguringView(status: "Initializing", message: "Please hold the device steady pointing horizontally in a well lit area.")
    case .normal:
      self.hideConfiguringView()
    case .notAvailable:
      self.showConfiguringView(status: "Not Available", message: "Only supported on Apple devices with an A9, A10, or A11 chip or newer. This includes all phones including the iPhone 6s/6s+ and newer as well as all iPad Pro models and the 2017 iPad.")
    }
  }
  
  // MARK: - Configuring View
  
  func showConfiguringView(status: String, message: String?) {
    
    // Check if already showing the configuring view
    if let configuringViewController = self.configuringViewController {
      configuringViewController.state = .statusMessage(status, message)
      return
    }
    
    // Create the configuring view
    let configuringViewController = ConfiguringViewController.newViewController(state: .statusMessage(status, message))
    configuringViewController.view.alpha = 0
    self.configuringViewController = configuringViewController
    let visualEffectContainerController = VisualEffectContainerViewController(embeddedViewController: configuringViewController, blurEffect: nil)
    self.configuringVisualEffectContainerViewController = visualEffectContainerController
    
    // Hide the buttons
    self.hideElements { [weak self] in
      if let strongSelf = self {
        strongSelf.add(childViewController: visualEffectContainerController, intoContainerView: strongSelf.view)
        
        // Animate show the configuring view
        let duration: TimeInterval = 0.3
        strongSelf.configuringVisualEffectContainerViewController?.update(blurEffect: UIBlurEffect(style: .dark), duration: duration)
        UIView.animate(withDuration: duration, animations: { [weak self] in
          self?.configuringViewController?.view.alpha = 1
        })
      }
    }
  }
  
  func hideConfiguringView() {
    
    guard let _ = self.configuringViewController, let configuringVisualEffectContainerViewController = self.configuringVisualEffectContainerViewController else {
      self.showElements()
      return
    }
    
    // Animate hide the configuring view
    let duration: TimeInterval = 0.3
    UIView.animate(withDuration: duration, animations: { [weak self] in
      self?.configuringViewController?.view.alpha = 0
    })
    configuringVisualEffectContainerViewController.update(blurEffect: nil, duration: duration) { [weak self] in
      self?.loadConfiguredNavigationBar()
      self?.showElements()
      if let configuringVisualEffectContainerViewController = self?.configuringVisualEffectContainerViewController {
        self?.remove(childViewController: configuringVisualEffectContainerViewController)
      }
      self?.configuringViewController = nil
      self?.configuringVisualEffectContainerViewController = nil
    }
  }
}
