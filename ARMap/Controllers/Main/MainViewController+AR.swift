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
  
  func userDidTap(savedLocation: SavedLocation) {
    self.presentLocationDetail(savedLocation: savedLocation)
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
  
  // MARK: - Configuring View
  
  func showConfiguringView(state: ARState) {
    
    // Check if already showing the configuring view
    if let configuringViewController = self.configuringViewController {
      configuringViewController.state = .statusMessage(state.status, state.message)
      return
    }
    
    // Create the configuring view
    let configuringViewController = ConfiguringViewController.newViewController(state: .statusMessage(state.status, state.message))
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
