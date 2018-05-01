//
//  BaseNavigationController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

class BaseNavigationController : UINavigationController, PresentableController {
  
  // MARK: - PresentableController
  
  var presentedMode: PresentationMode = .modal(.formSheet, .coverVertical)
  var presentationManager: UIViewControllerTransitioningDelegate? = nil
  var currentFlowInitialController: PresentableController? = nil
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.configureDefaultBackButton()
    
    self.navigationBar.prefersLargeTitles = true
  }
  
  // MARK: - NavigationBarStyle
  
  enum NavigationBarStyle {
    case standard, transparent, transparentBlueTint
    
    var isTranslucent: Bool {
      switch self {
      case .standard:
        return false
      case .transparent, .transparentBlueTint:
        return true
      }
    }
    
    var barTintColor: UIColor {
      switch self {
      case .standard:
        return .white
      case .transparent, .transparentBlueTint:
        return .clear
      }
    }
    
    var tintColor: UIColor {
      switch self {
      case .standard:
        return .kozBlue
      case .transparent:
        return .white
      case .transparentBlueTint:
        return .kozBlue
      }
    }
    
    var titleTextAttributes: [NSAttributedStringKey : Any]? {
      switch self {
      case .standard:
        return [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: .regular), NSAttributedStringKey.foregroundColor: UIColor.black ]
      case .transparent:
        return [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: .regular), NSAttributedStringKey.foregroundColor: UIColor.white ]
      case .transparentBlueTint:
        return [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: .regular), NSAttributedStringKey.foregroundColor: UIColor.black ]
      }
    }
    
    var largeTitleTextAttributes: [NSAttributedStringKey : Any]? {
      switch self {
      case .standard:
        return [ NSAttributedStringKey.foregroundColor: UIColor.black ]
      case .transparent:
        return [ NSAttributedStringKey.foregroundColor: UIColor.white ]
      case .transparentBlueTint:
        return [ NSAttributedStringKey.foregroundColor: UIColor.black ]
      }
    }
    
    var backIndicator: UIImage? {
      switch self {
      default:
        return nil
      }
    }
    
    var backItemTitle: String {
      switch self {
      default:
        return ""
      }
    }
  }
  
  convenience init(navigationBarStyle: NavigationBarStyle) {
    self.init()
    
    self.navigationBarStyle = navigationBarStyle
  }
  
  var navigationBarStyle: NavigationBarStyle = .standard {
    didSet {
      if self.navigationBarStyle != oldValue {
        self.applyNavigationBarStyles()
      }
    }
  }
  
  private func applyNavigationBarStyles() {
    
    // Title and tint
    self.navigationBar.barTintColor = self.navigationBarStyle.barTintColor
    self.navigationBar.tintColor = self.navigationBarStyle.tintColor
    self.navigationBar.titleTextAttributes = self.navigationBarStyle.titleTextAttributes
    self.navigationBar.largeTitleTextAttributes = self.navigationBarStyle.largeTitleTextAttributes
    self.navigationBar.isTranslucent = self.navigationBarStyle.isTranslucent
    
    switch self.navigationBarStyle {
    case .transparent, .transparentBlueTint:
      self.navigationBar.setBackgroundImage(UIImage(), for: .default)
      self.navigationBar.shadowImage = UIImage()
      self.navigationBar.backgroundColor = .clear
    default: break
    }
    
    // Update the status bar
    self.setNeedsStatusBarAppearanceUpdate()
  }
  
  // MARK: - Status Bar Style
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    switch self.navigationBarStyle {
    case .standard, .transparentBlueTint:
      switch self.presentedMode {
      case .modal(.fullScreen, _), .modal(.overFullScreen, _):
        return .default
      default:
        return .lightContent
      }
    case .transparent:
      return .lightContent
    }
  }
  override var prefersStatusBarHidden: Bool {
    
    guard let topViewController = self.viewControllers.last else {
      return false
    }
    
    return topViewController.prefersStatusBarHidden
  }
  
  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return .slide
  }
}
