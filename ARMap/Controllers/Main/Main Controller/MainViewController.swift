//
//  MainViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

class MainViewController : BaseViewController {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> MainViewController {
    return self.newViewController(fromStoryboardWithName: "Main")
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var tabBarVisualEffectView: UIVisualEffectView!
  @IBOutlet weak var homeTabBarContainerView: UIView!
  weak var homeTabBarView: HomeTabBarView?
  
  internal var arViewController: ARViewController? = nil
  
  internal var appMode: AppMode = .myPlacemark {
    didSet {
      if self.appMode != oldValue {
        self.arViewController?.appMode = self.appMode
        self.homeTabBarView?.appMode = appMode
      }
    }
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Navigation bar
    self.navigationItem.title = nil
    self.navigationItem.largeTitleDisplayMode = .never
    
    // Configure views
    self.configureView()
    
    // Configure the current app mode
    self.appMode = Defaults.shared.appMode
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Notifications
    NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification(_:)), name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification(_:)), name: .UIKeyboardWillHide, object: nil)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Views
  
  func configureView() {
    
    // Configure the home tab bar view
    let homeTabBarView = HomeTabBarView.newView(appMode: self.appMode, delegate: self)
    homeTabBarView.backgroundColor = .clear
    self.homeTabBarView = homeTabBarView
    homeTabBarView.addToContainer(self.homeTabBarContainerView)
    
    // For simulators add an image view to give simulated location context
    if UIDevice.current.isSimulator {
      let imageView = UIImageView(image: #imageLiteral(resourceName: "denverCityScape"))
      imageView.contentMode = .scaleAspectFill
      imageView.addToContainer(self.view, atIndex: 1)
    }
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let arViewController = segue.destination as? ARViewController {
      arViewController.delegate = self
      arViewController.trackingStateDelegate = self
      arViewController.appMode = self.appMode
      self.arViewController = arViewController
    }
  }
  
  // MARK: - Keyboard
  
  @objc func handleKeyboardNotification(_ notification: NSNotification) {
    
    guard let presentedViewController = self.presentedViewController as? KeyboardFrameRespondable, let userInfo = notification.userInfo else {
      return
    }
    
    // Keyboard presentation properties
    let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
    let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
    let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
    let animationCurve = UIViewAnimationOptions(rawValue: animationCurveRaw)
    let keyboardOffset: CGFloat
    if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
      keyboardOffset = 0
    } else {
      let safeAreaOffset = self.view.safeAreaLayoutGuide.layoutFrame.origin.y / 4
      keyboardOffset = (endFrame?.size.height ?? 0.0) - safeAreaOffset
    }
    
    // Calculate the new frame
    let xOffset = presentedViewController.view.frame.origin.x
    let presentedViewControllerHeight = presentedViewController.view.bounds.height
    let yOffset = self.view.bounds.height - keyboardOffset - presentedViewControllerHeight
    let newFrame = CGRect(x: xOffset, y: max(yOffset, 100), width: presentedViewController.view.bounds.width, height: presentedViewControllerHeight)
    
    // Perform the animation
    UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: { [weak self] in
      self?.presentedViewController?.view.frame = newFrame
    })
  }
  
  // MARK: - Showing and Enabling Views
  
  func showAllElements() {
    self.tabBarVisualEffectView.effect = UIBlurEffect(style: .light)
    self.homeTabBarContainerView.alpha = 1
  }
  
  func enableAllElements() {
    self.homeTabBarContainerView.isUserInteractionEnabled = true
  }
  
  func disableAllElements() {
    self.homeTabBarContainerView.isUserInteractionEnabled = false
  }
  
  func hideAllElements() {
    self.tabBarVisualEffectView.effect = nil
    self.homeTabBarContainerView.alpha = 0
  }
}
