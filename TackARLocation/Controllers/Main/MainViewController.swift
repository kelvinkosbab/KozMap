//
//  MainViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
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
  
  var arViewController: ARViewController? = nil
  
  var configuringViewController: ConfiguringViewController? = nil
  var configuringVisualEffectContainerViewController: VisualEffectContainerViewController? = nil
  
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
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let arViewController = segue.destination as? ARViewController {
      arViewController.trackingStateDelegate = self
      self.arViewController = arViewController
    }
  }
  
  // MARK: - Navigation Items
  
  func loadConfiguredNavigationBar() {
    self.navigationItem.title = "KozMap"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "assetOptions"), style: .plain, target: self, action: #selector(self.settingsButtonSelected))
    self.navigationItem.hidesBackButton = false
  }
  
  func clearNavigationBar() {
    self.navigationItem.title = nil
    self.navigationItem.leftBarButtonItem = nil
    self.navigationItem.rightBarButtonItem = nil
    self.navigationItem.hidesBackButton = true
  }
  
  // MARK: - Actions
  
  @IBAction func addButtonSelected() {
    
    // Instantiate the location detail view controller
    let addLocationViewController = AddLocationViewController.newViewController(locationDetailDelegate: self, searchDelegate: self)
    addLocationViewController.modalPresentationStyle = .popover
    addLocationViewController.popoverPresentationController?.delegate = self
    addLocationViewController.preferredContentSize = CGSize(width: self.view.bounds.width - 16, height: addLocationViewController.preferredContentHeight)
    addLocationViewController.popoverPresentationController?.sourceView = self.addButton
    addLocationViewController.popoverPresentationController?.sourceRect = self.addButton.bounds
    self.present(addLocationViewController, animated: true, completion: nil)
  }
  
  @IBAction func listButtonSelected() {
    
    // Instantiate the location list view controller
    let locationListViewController = LocationListViewController.newViewController(delegate: self)
    let viewControllerToPresent = VisualEffectContainerViewController(embeddedViewController: locationListViewController)
    viewControllerToPresent.modalPresentationStyle = .popover
    viewControllerToPresent.popoverPresentationController?.delegate = self
    viewControllerToPresent.preferredContentSize = CGSize(width: self.view.bounds.width - 16, height: min(self.view.bounds.height, 300))
    viewControllerToPresent.popoverPresentationController?.sourceView = self.listButton
    viewControllerToPresent.popoverPresentationController?.sourceRect = self.listButton.bounds
    self.present(viewControllerToPresent, animated: true, completion: nil)
  }
  
  @objc func settingsButtonSelected() {
    let settingsViewController = SettingsViewController.newViewController()
    let offset = UIApplication.shared.statusBarFrame.height + (self.navigationController?.navigationBar.frame.height ?? 0)
    let interactiveElement = InteractiveElement(size: settingsViewController.defaultContentHeight, offset: offset, view: settingsViewController.view)
    let viewControllerToPresent = VisualEffectContainerViewController(embeddedViewController: settingsViewController, blurEffect: UIBlurEffect(style: .dark))
    self.present(viewController: viewControllerToPresent, withMode: .topDown, inNavigationController: false, dismissInteractiveElement: interactiveElement)
  }
  
  // MARK: - Navigation
  
  func presentLocationDetail(savedLocation: SavedLocation) {
    
    // Instantiate the location detail view controller
    let addLocationViewController = LocationDetailViewController.newViewController(savedLocation: savedLocation, delegate: self)
    let viewControllerToPresent = VisualEffectContainerViewController(embeddedViewController: addLocationViewController)
    viewControllerToPresent.modalPresentationStyle = .popover
    viewControllerToPresent.popoverPresentationController?.delegate = self
    viewControllerToPresent.preferredContentSize = CGSize(width: self.view.bounds.width - 16, height: addLocationViewController.preferredContentHeight)
    viewControllerToPresent.popoverPresentationController?.sourceView = self.listButton
    viewControllerToPresent.popoverPresentationController?.sourceRect = self.listButton.bounds
    self.present(viewControllerToPresent, animated: true, completion: nil)
  }
  
  func presentLocationDetail(mapItem: MapItem) {
    
    // Instantiate the location detail view controller
    let addLocationViewController = LocationDetailViewController.newViewController(mapItem: mapItem, delegate: self)
    let viewControllerToPresent = VisualEffectContainerViewController(embeddedViewController: addLocationViewController)
    viewControllerToPresent.modalPresentationStyle = .popover
    viewControllerToPresent.popoverPresentationController?.delegate = self
    viewControllerToPresent.preferredContentSize = CGSize(width: self.view.bounds.width - 16, height: addLocationViewController.preferredContentHeight)
    viewControllerToPresent.popoverPresentationController?.sourceView = self.addButton
    viewControllerToPresent.popoverPresentationController?.sourceRect = self.addButton.bounds
    self.present(viewControllerToPresent, animated: true, completion: nil)
  }
  
  // MARK: - Hiding and Showing Elements
  
  func showElements(completion: (() -> Void)? = nil) {
    UIView.animate(withDuration: 0.3, animations: { [weak self] in
      self?.aboveSafeAreaVisualEffectView.effect = UIBlurEffect(style: .dark)
      self?.listVisualEffectView.effect = UIBlurEffect(style: .light)
      self?.listButton.alpha = 1
      self?.addVisualEffectView.effect = UIBlurEffect(style: .light)
      self?.addButton.alpha = 1
    }) { [weak self] _ in
      self?.listButton.isUserInteractionEnabled = true
      self?.addButton.isUserInteractionEnabled = true
      self?.loadConfiguredNavigationBar()
      completion?()
    }
  }
  
  func hideElements(completion: (() -> Void)? = nil) {
    self.clearNavigationBar()
    self.listButton.isUserInteractionEnabled = false
    self.addButton.isUserInteractionEnabled = false
    UIView.animate(withDuration: 0.3, animations: { [weak self] in
      self?.aboveSafeAreaVisualEffectView.effect = nil
      self?.listVisualEffectView.effect = nil
      self?.listButton.alpha = 0
      self?.addVisualEffectView.effect = nil
      self?.addButton.alpha = 0
    }) { _ in
      completion?()
    }
  }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension MainViewController : UIPopoverPresentationControllerDelegate {
  
  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
  }
}
