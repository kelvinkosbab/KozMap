//
//  TopKnobVisualEffectContainerViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 1/3/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class TopKnobVisualEffectContainerViewController : BaseViewController, DesiredContentHeightDelegate, KeyboardFrameRespondable {
  
  // MARK: - Init
  
  convenience init(embeddedViewController: UIViewController, topKnobBlurEffect: UIBlurEffect? = UIBlurEffect(style: .dark), backgroundBlurEffect: UIBlurEffect? = UIBlurEffect(style: .prominent)) {
    self.init()
    self.topKnobBlurEffect = topKnobBlurEffect
    self.backgroundBlurEffect = backgroundBlurEffect
    self.embeddedViewController = embeddedViewController
  }
  
  // MARK: - DesiredContentHeightDelegate
  
  var desiredContentHeight: CGFloat {
    if let desiredContentHeightDelegate = self.embeddedViewController as? DesiredContentHeightDelegate {
      return desiredContentHeightDelegate.desiredContentHeight + self.topKnobSpace + self.knobHeight + self.bottomKnobSpace
    }
    return UIScreen.main.bounds.height - 175
  }
  
  // MARK: - Properties
  
  weak var topKnobVisualEffectView: UIVisualEffectView?
  weak var backgroundVisualEffectView: UIVisualEffectView?
  weak var embeddedControllerContainerView: UIView?
  
  var embeddedViewController: UIViewController?
  var topKnobBlurEffect: UIBlurEffect? = UIBlurEffect(style: .dark)
  var backgroundBlurEffect: UIBlurEffect? = UIBlurEffect(style: .prominent)
  
  let topKnobSpace: CGFloat = 5
  let knobHeight: CGFloat = 3
  let bottomKnobSpace: CGFloat = 10
  let knobWidth: CGFloat = 40
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = .clear
    self.configureVisualEffectViews()
    self.configureEmbeddedViewController()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - Configuration
  
  func configureVisualEffectViews() {
    
    // Configure background visual effect view
    let backgroundVisualEffectView = UIVisualEffectView(effect: self.backgroundBlurEffect)
    backgroundVisualEffectView.addToContainer(self.view)
    self.backgroundVisualEffectView = backgroundVisualEffectView
    
    // Configure knob view
    let topKnobVisualEffectView = UIVisualEffectView(effect: self.topKnobBlurEffect)
    topKnobVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
    backgroundVisualEffectView.contentView.addSubview(topKnobVisualEffectView)
    let knobHeight = NSLayoutConstraint(item: topKnobVisualEffectView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.knobHeight)
    let knobWidth = NSLayoutConstraint(item: topKnobVisualEffectView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.knobWidth)
    topKnobVisualEffectView.layer.cornerRadius = self.knobHeight / 2
    topKnobVisualEffectView.layer.masksToBounds = true
    topKnobVisualEffectView.clipsToBounds = true
    topKnobVisualEffectView.addConstraints([ knobHeight, knobWidth ])
    let knobTop = NSLayoutConstraint(item: topKnobVisualEffectView, attribute: .top, relatedBy: .equal, toItem: backgroundVisualEffectView.contentView, attribute: .top, multiplier: 1, constant: self.topKnobSpace)
    let knobCenterX = NSLayoutConstraint(item: topKnobVisualEffectView, attribute: .centerX, relatedBy: .equal, toItem: backgroundVisualEffectView.contentView, attribute: .centerX, multiplier: 1, constant: 0)
    backgroundVisualEffectView.contentView.addConstraints([ knobTop, knobCenterX ])
    self.topKnobVisualEffectView = topKnobVisualEffectView
    
    // Configure container view
    let embeddedControllerContainerView = UIView()
    embeddedControllerContainerView.translatesAutoresizingMaskIntoConstraints = false
    backgroundVisualEffectView.contentView.addSubview(embeddedControllerContainerView)
    let containerTop = NSLayoutConstraint(item: embeddedControllerContainerView, attribute: .top, relatedBy: .equal, toItem: topKnobVisualEffectView, attribute: .bottom, multiplier: 1, constant: self.bottomKnobSpace)
    let containerBottom = NSLayoutConstraint(item: embeddedControllerContainerView, attribute: .bottom, relatedBy: .equal, toItem: backgroundVisualEffectView.contentView, attribute: .bottom, multiplier: 1, constant: 0)
    let containerLeading = NSLayoutConstraint(item: embeddedControllerContainerView, attribute: .leading, relatedBy: .equal, toItem: backgroundVisualEffectView.contentView, attribute: .leading, multiplier: 1, constant: 0)
    let containerTrailing = NSLayoutConstraint(item: embeddedControllerContainerView, attribute: .trailing, relatedBy: .equal, toItem: backgroundVisualEffectView.contentView, attribute: .trailing, multiplier: 1, constant: 0)
    backgroundVisualEffectView.contentView.addConstraints([ containerTop, containerBottom, containerLeading, containerTrailing ])
    self.embeddedControllerContainerView = embeddedControllerContainerView
  }
  
  func configureEmbeddedViewController() {
    // Configure the embedded view controller
    if let embeddedViewController = self.embeddedViewController, let embeddedControllerContainerView = self.embeddedControllerContainerView {
      embeddedViewController.view.backgroundColor = .clear
      self.add(childViewController: embeddedViewController, intoContainerView: embeddedControllerContainerView)
    }
  }
  
  // MARK: - Animating
  
  func update(topKnobBlurEffect: UIBlurEffect?, backgroundBlurEffect: UIBlurEffect?, duration: TimeInterval?, completion: (() -> Void)? = nil) {
    self.topKnobBlurEffect = topKnobBlurEffect
    self.backgroundBlurEffect = backgroundBlurEffect
    if let duration = duration {
      UIView.animate(withDuration: duration, animations: { [weak self] in
        self?.topKnobVisualEffectView?.effect = topKnobBlurEffect
        self?.backgroundVisualEffectView?.effect = backgroundBlurEffect
      }) { _ in
        completion?()
      }
    } else {
      self.topKnobVisualEffectView?.effect = topKnobBlurEffect
      self.backgroundVisualEffectView?.effect = backgroundBlurEffect
      completion?()
    }
  }
}
