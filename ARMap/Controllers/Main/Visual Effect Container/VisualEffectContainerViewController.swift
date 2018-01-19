//
//  VisualEffectContainerViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/12/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

class VisualEffectContainerViewController : BaseViewController, KeyboardFrameRespondable {
  
  // MARK: - Init
  
  convenience init(embeddedViewController: UIViewController, blurEffect: UIBlurEffect? = UIBlurEffect(style: .light)) {
    self.init()
    self.blurEffect = blurEffect
    self.embeddedViewController = embeddedViewController
  }
  
  // MARK: - Properties
  
  weak var visualEffectView: UIVisualEffectView?
  
  var embeddedViewController: UIViewController?
  var blurEffect: UIBlurEffect? = UIBlurEffect(style: .light)
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = .clear
    
    // Configure visual effect view
    let visualEffectView = UIVisualEffectView(effect: self.blurEffect)
    visualEffectView.addToContainer(self.view)
    self.visualEffectView = visualEffectView
    
    // Configure the embedded view controller
    if let embeddedViewController = self.embeddedViewController {
      embeddedViewController.view.backgroundColor = .clear
      self.add(childViewController: embeddedViewController, intoContainerView: visualEffectView.contentView)
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    if let embeddedViewController = self.embeddedViewController {
      return embeddedViewController.preferredStatusBarStyle
    }
    return super.preferredStatusBarStyle
  }
  
  // MARK: - Animating
  
  func update(blurEffect: UIBlurEffect?, duration: TimeInterval?, completion: (() -> Void)? = nil) {
    self.blurEffect = blurEffect
    if let duration = duration {
      UIView.animate(withDuration: duration, animations: { [weak self] in
        self?.visualEffectView?.effect = blurEffect
      }) { _ in
        completion?()
      }
    } else {
      self.visualEffectView?.effect = blurEffect
      completion?()
    }
  }
}
