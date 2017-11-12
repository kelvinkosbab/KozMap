//
//  VisualEffectContainerViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/12/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit

class VisualEffectContainerViewController : BaseViewController {
  
  // MARK: - Init
  
  convenience init(embeddedViewController: UIViewController, blurEffectStyle: UIBlurEffectStyle = .prominent) {
    self.init()
    self.blurEffectStyle = blurEffectStyle
    self.embeddedViewController = embeddedViewController
  }
  
  // MARK: - Properties
  
  weak var visualEffectView: UIVisualEffectView?
  
  var embeddedViewController: UIViewController?
  var blurEffectStyle: UIBlurEffectStyle = .prominent
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = .clear
    
    // Configure visual effect view
    let blurEffect = UIBlurEffect(style: self.blurEffectStyle)
    let visualEffectView = UIVisualEffectView(effect: blurEffect)
    visualEffectView.addToContainer(self.view)
    self.visualEffectView = visualEffectView
    
    // Configure the embedded view controller
    if let embeddedViewController = self.embeddedViewController {
      embeddedViewController.view.backgroundColor = .clear
      self.add(childViewController: embeddedViewController, intoContainerView: visualEffectView.contentView)
    }
  }
}
