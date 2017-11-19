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
  
  @IBOutlet weak var addVisualEffectView: UIVisualEffectView!
  @IBOutlet weak var addButton: UIButton!
  @IBOutlet weak var listVisualEffectView: UIVisualEffectView!
  @IBOutlet weak var listButton: UIButton!
  
  weak var arViewController: ARViewController? = nil
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = "KozMap"
    self.navigationItem.largeTitleDisplayMode = .never
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "assetOptions"), style: .plain, target: self, action: #selector(self.settingsButtonSelected))
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
      self.arViewController = arViewController
    }
  }
  
  // MARK: - Actions
  
  @IBAction func addButtonSelected() {
    
    // Instantiate the location detail view controller
    let currentLocation = LocationManager.shared.currentLocation
    let addLocationViewController = AddLocationViewController.newViewController(location: currentLocation, locationDetailDelegate: self, searchDelegate: self)
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
    let viewControllerToPresent = VisualEffectContainerViewController(embeddedViewController: settingsViewController, blurEffectStyle: .dark)
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
}

// MARK: - UIPopoverPresentationControllerDelegate

extension MainViewController : UIPopoverPresentationControllerDelegate {
  
  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
  }
}
