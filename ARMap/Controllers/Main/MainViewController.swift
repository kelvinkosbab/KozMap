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
  internal var configuringViewController: ConfiguringViewController?
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.largeTitleDisplayMode = .never
    self.clearNavigationBar()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Style visual effect views
    self.addVisualEffectView.layer.cornerRadius = 28
    self.addVisualEffectView.layer.masksToBounds = true
    self.addVisualEffectView.clipsToBounds = true
    self.listVisualEffectView.layer.cornerRadius = 28
    self.listVisualEffectView.layer.masksToBounds = true
    self.listVisualEffectView.clipsToBounds = true
    
    // Notifications
    NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification(_:)), name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification(_:)), name: .UIKeyboardWillHide, object: nil)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let arViewController = segue.destination as? ARViewController {
      arViewController.delegate = self
      arViewController.trackingStateDelegate = self
      self.arViewController = arViewController
    }
  }
  
  // MARK: - Navigation Items
  
  func loadConfiguredNavigationBar() {
    self.navigationItem.title = BuildManager.shared.buildTarget.appName
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "assetOptions"), style: .plain, target: self, action: #selector(self.settingsButtonSelected))
  }
  
  func clearNavigationBar() {
    self.navigationItem.title = nil
    self.navigationItem.leftBarButtonItem = nil
    self.navigationItem.rightBarButtonItem = nil
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
    self.present(viewController: settingsViewController, withMode: .topKnobBottomUp, options: [ .withoutNavigationController, .presentingViewControllerDelegate(self) ])
  }
  
  func presentPlacemarkList() {
    
    guard self.presentedViewController == nil else {
      return
    }
    
    let locationListViewController = LocationListViewController.newViewController(delegate: self)
    self.present(viewController: locationListViewController, withMode: .topKnobBottomUp, options: [ .withoutNavigationController, .presentingViewControllerDelegate(self) ])
  }
  
  func presentAddLocation() {
    
    guard self.presentedViewController == nil else {
      return
    }
    
    let addLocationContainerViewController = AddLocationContainerViewController.newViewController(locationDetailDelegate: self, searchDelegate: self)
    self.present(viewController: addLocationContainerViewController, withMode: .topKnobBottomUp, options: [ .withoutNavigationController, .presentingViewControllerDelegate(self) ])
  }
  
  func presentAddLocation(mapItem: MapItem) {
    
    guard self.presentedViewController == nil else {
      return
    }
    
    let addLocationViewController = AddLocationViewController.newViewController(mapItem: mapItem, delegate: self)
    self.present(viewController: addLocationViewController, withMode: .topKnobBottomUp, options: [ .withoutNavigationController, .presentingViewControllerDelegate(self) ])
  }
  
  func presentLocationDetail(placemark: Placemark) {
    
    guard self.presentedViewController == nil else {
      return
    }
    
    let locationDetailViewController = LocationDetailViewController.newViewController(placemark: placemark)
    self.present(viewController: locationDetailViewController, withMode: .topKnobBottomUp, options: [ .withoutNavigationController, .presentingViewControllerDelegate(self) ])
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
      keyboardOffset = endFrame?.size.height ?? 0.0
    }
    
    // Calculate the new frame
    let xOffset = presentedViewController.view.frame.origin.x
    let yOffset = self.view.bounds.height - keyboardOffset - presentedViewController.view.bounds.height
    let newFrame = CGRect(x: xOffset, y: max(yOffset, 0), width: presentedViewController.view.bounds.width, height: presentedViewController.view.bounds.height)
    
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
    self.disableAllElements()
  }
  
  func isPresentingViewController(_ viewController: UIViewController?) {
    self.hideAllElements()
  }
  
  func didPresentViewController(_ viewController: UIViewController?) {}
  
  func willDismissViewController(_ viewController: UIViewController) {}
  
  func isDismissingViewController(_ viewController: UIViewController?) {
    self.showAllElements()
  }
  
  func didDismissViewController(_ viewController: UIViewController?) {
    let contentViewController = (viewController as? UINavigationController)?.viewControllers.first ?? viewController
    
    // Disable and hide navigation elements when presenting configuring view
    if let _ = contentViewController as? ConfiguringViewController {
      self.configuringViewController = nil
      
    }
    
    // All presentations
    self.enableAllElements()
  }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension MainViewController : UIPopoverPresentationControllerDelegate {
  
  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
  }
}
