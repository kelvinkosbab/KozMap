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
  
  @IBOutlet weak var aboveSafeAreaVisualEffectView: UIVisualEffectView!
  @IBOutlet weak var addVisualEffectView: UIVisualEffectView!
  @IBOutlet weak var addButton: UIButton!
  @IBOutlet weak var listVisualEffectView: UIVisualEffectView!
  @IBOutlet weak var listButton: UIButton!
  
  internal var arViewController: ARViewController? = nil
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.largeTitleDisplayMode = .never
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
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    if self.addVisualEffectView.layer.cornerRadius != 28 {
      self.addVisualEffectView.layer.cornerRadius = 28
      self.addVisualEffectView.layer.masksToBounds = true
      self.addVisualEffectView.clipsToBounds = true
    }
    if self.listVisualEffectView.layer.cornerRadius != 28 {
      self.listVisualEffectView.layer.cornerRadius = 28
      self.listVisualEffectView.layer.masksToBounds = true
      self.listVisualEffectView.clipsToBounds = true
    }
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let arViewController = segue.destination as? ARViewController {
      arViewController.delegate = self
      arViewController.trackingStateDelegate = self
      self.arViewController = arViewController
    }
  }
  
  // MARK: - Actions
  
  @IBAction func addButtonSelected() {
    self.presentAddLocation()
  }
  
  @IBAction func listButtonSelected() {
    self.presentPlacemarkList()
  }
  
  @objc func settingsButtonSelected() {
    self.presentSettings()
  }
  
  // MARK: - Navigation
  
  func presentSettings() {
    
    guard self.presentedViewController == nil else {
      return
    }
    
    let settingsViewController = SettingsViewController.newViewController()
    self.present(viewController: settingsViewController, withMode: .custom(.topKnobBottomUp), options: [ .withoutNavigationController, .presentingViewControllerDelegate(self) ])
  }
  
  func presentPlacemarkList() {
    
    guard self.presentedViewController == nil else {
      return
    }
    
    let locationListViewController = LocationListViewController.newViewController(delegate: self)
    self.present(viewController: locationListViewController, withMode: .custom(.topKnobBottomUp), options: [ .withoutNavigationController, .presentingViewControllerDelegate(self) ])
  }
  
  func presentAddLocation() {
    
    guard self.presentedViewController == nil else {
      return
    }
    
    let addLocationContainerViewController = AddLocationContainerViewController.newViewController(locationDetailDelegate: self, searchDelegate: self)
    self.present(viewController: addLocationContainerViewController, withMode: .custom(.topKnobBottomUp), options: [ .withoutNavigationController, .presentingViewControllerDelegate(self) ])
  }
  
  func presentAddLocation(mapItem: MapItem) {
    
    guard self.presentedViewController == nil else {
      return
    }
    
    let addLocationViewController = AddLocationViewController.newViewController(mapItem: mapItem, delegate: self)
    self.present(viewController: addLocationViewController, withMode: .custom(.topKnobBottomUp), options: [ .withoutNavigationController, .presentingViewControllerDelegate(self) ])
  }
  
  func presentLocationDetail(placemark: Placemark) {
    
    guard self.presentedViewController == nil else {
      return
    }
    
    let locationDetailViewController = LocationDetailViewController.newViewController(placemark: placemark)
    self.present(viewController: locationDetailViewController, withMode: .custom(.topKnobBottomUp), options: [ .withoutNavigationController, .presentingViewControllerDelegate(self) ])
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
    let presentedViewControllerHeight = presentedViewController.preferredContentSize.height > 0 ? presentedViewController.preferredContentSize.height : presentedViewController.view.bounds.height
    let yOffset = self.view.bounds.height - keyboardOffset - presentedViewControllerHeight
    let newFrame = CGRect(x: xOffset, y: max(yOffset, 0), width: presentedViewController.view.bounds.width, height: presentedViewControllerHeight)
    
    // Perform the animation
    UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: { [weak self] in
      self?.presentedViewController?.view.frame = newFrame
    })
  }
  
  // MARK: - Showing and Enabling Views
  
  func showAllElements() {
    self.aboveSafeAreaVisualEffectView.effect = UIBlurEffect(style: .dark)
    self.listVisualEffectView.effect = UIBlurEffect(style: .light)
    self.listButton.alpha = 1
    self.addVisualEffectView.effect = UIBlurEffect(style: .light)
    self.addButton.alpha = 1
    
    // Navigation bar
    self.navigationController?.navigationBar.alpha = 1
  }
  
  func enableAllElements() {
    self.listButton.isUserInteractionEnabled = true
    self.addButton.isUserInteractionEnabled = true
    
    // Navigation bar
    self.navigationController?.navigationBar.alpha = 1
    if self.navigationItem.title == nil {
      self.navigationItem.title = BuildManager.shared.buildTarget.appName
    }
    if self.navigationItem.rightBarButtonItem == nil {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "assetOptions"), style: .plain, target: self, action: #selector(self.settingsButtonSelected))
    }
  }
  
  func disableAllElements() {
    self.listButton.isUserInteractionEnabled = false
    self.addButton.isUserInteractionEnabled = false
    
    // Navigation bar
    self.navigationController?.navigationBar.alpha = 0
    self.navigationItem.title = nil
    self.navigationItem.rightBarButtonItem = nil
  }
  
  func hideAllElements() {
    self.aboveSafeAreaVisualEffectView.effect = nil
    self.listVisualEffectView.effect = nil
    self.listButton.alpha = 0
    self.addVisualEffectView.effect = nil
    self.addButton.alpha = 0
    
    // Navigation Bar
    self.navigationController?.navigationBar.alpha = 0
  }
}

// MARK: - PresentingViewControllerDelegate

extension MainViewController : PresentingViewControllerDelegate {
  
  func willPresentViewController(_ viewController: UIViewController) {
    self.disableAllElements()
  }
  
  func isPresentingViewController(_ viewController: UIViewController?) {
    self.hideAllElements()
  }
  
  func didPresentViewController(_ viewController: UIViewController?) {
    self.hideAllElements()
  }
  
  func willDismissViewController(_ viewController: UIViewController) {}
  
  func isDismissingViewController(_ viewController: UIViewController?) {
    self.showAllElements()
  }
  
  func didDismissViewController(_ viewController: UIViewController?) {
    
    // All presentations
    self.enableAllElements()
  }
  
  func didCancelDissmissViewController(_ viewController: UIViewController?) {
    self.hideAllElements()
    self.disableAllElements()
  }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension MainViewController : UIPopoverPresentationControllerDelegate {
  
  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
  }
}
