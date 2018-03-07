//
//  MainViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

class MainViewController : BaseViewController, LocationDetailNavigationDelegate {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> MainViewController {
    return self.newViewController(fromStoryboardWithName: "Main")
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var tabBarVisualEffectView: UIVisualEffectView!
  @IBOutlet weak var addButton: UIButton!
  @IBOutlet weak var listButton: UIButton!
  @IBOutlet weak var settingsButton: UIButton!
  
  internal var arViewController: ARViewController? = nil
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = nil
    self.navigationItem.largeTitleDisplayMode = .never
    
    // For simulators add an image view to give simulated location context
    if UIDevice.current.isSimulator {
      let imageView = UIImageView(image: #imageLiteral(resourceName: "denverCityScape"))
      imageView.contentMode = .scaleAspectFill
      imageView.addToContainer(self.view, atIndex: 1)
    }
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
  
  @IBAction func settingsButtonSelected() {
    self.presentSettings()
  }
  
  // MARK: - Navigation
  
  func presentSettings() {
    
    guard self.presentedViewController == nil else {
      return
    }
    
    let settingsViewController = SettingsViewController.newViewController()
    if UIDevice.current.isPhone {
      self.present(viewController: settingsViewController, withMode: .custom(.topKnobBottomUp), options: [ .withoutNavigationController, .presentingViewControllerDelegate(self) ])
    } else {
      self.present(viewController: settingsViewController, withMode: .modal(.formSheet, .coverVertical), options: [])
    }
  }
  
  func presentPlacemarkList() {
    
    guard self.presentedViewController == nil else {
      return
    }
    
    let locationListViewController = LocationListViewController.newViewController(delegate: self)
    if UIDevice.current.isPhone {
      self.present(viewController: locationListViewController, withMode: .custom(.topKnobBottomUp), options: [ .withoutNavigationController, .presentingViewControllerDelegate(self) ])
    } else {
      self.present(viewController: locationListViewController, withMode: .modal(.formSheet, .coverVertical), options: [])
    }
  }
  
  func presentAddLocation() {
    
    let modeChooserViewController = ModeChooserViewController.newViewController(delegate: self)
    self.present(viewController: modeChooserViewController, withMode: .custom(.visualEffectFade), options: [ .presentingViewControllerDelegate(self) ])
    return
    
    guard self.presentedViewController == nil else {
      return
    }
    
    let addLocationContainerViewController = AddLocationContainerViewController.newViewController(locationDetailDelegate: self, searchDelegate: self)
    if UIDevice.current.isPhone {
      self.present(viewController: addLocationContainerViewController, withMode: .custom(.topKnobBottomUp), options: [ .withoutNavigationController, .presentingViewControllerDelegate(self) ])
    } else {
      self.present(viewController: addLocationContainerViewController, withMode: .modal(.formSheet, .coverVertical), options: [])
    }
  }
  
  func presentAddLocation(mapItem: MapItem) {
    
    guard self.presentedViewController == nil else {
      return
    }
    
    let addLocationViewController = AddLocationViewController.newViewController(mapItem: mapItem, delegate: self)
    if UIDevice.current.isPhone {
      self.present(viewController: addLocationViewController, withMode: .custom(.topKnobBottomUp), options: [ .withoutNavigationController, .presentingViewControllerDelegate(self) ])
    } else {
      self.present(viewController: addLocationViewController, withMode: .modal(.formSheet, .coverVertical), options: [])
    }
  }
  
  func presentLocationDetail(placemark: Placemark) {
    
    guard self.presentedViewController == nil else {
      return
    }
    
    let locationDetailViewController = self.getPlacemarkDetailViewController(placemark: placemark)
    if UIDevice.current.isPhone {
      self.present(viewController: locationDetailViewController, withMode: .custom(.topKnobBottomUp), options: [ .withoutNavigationController, .presentingViewControllerDelegate(self) ])
    } else {
      self.present(viewController: locationDetailViewController, withMode: .modal(.formSheet, .coverVertical), options: [])
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
    self.listButton.alpha = 1
    self.addButton.alpha = 1
    self.settingsButton.alpha = 1
  }
  
  func enableAllElements() {
    self.listButton.isUserInteractionEnabled = true
    self.addButton.isUserInteractionEnabled = true
    self.settingsButton.isUserInteractionEnabled = true
  }
  
  func disableAllElements() {
    self.listButton.isUserInteractionEnabled = false
    self.addButton.isUserInteractionEnabled = false
    self.settingsButton.isUserInteractionEnabled = false
  }
  
  func hideAllElements() {
    self.tabBarVisualEffectView.effect = nil
    self.listButton.alpha = 0
    self.addButton.alpha = 0
    self.settingsButton.alpha = 0
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
