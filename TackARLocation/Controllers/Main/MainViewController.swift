//
//  MainViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit

class MainViewController : UIViewController {
  
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
    
    self.navigationItem.title = "ARMap"
    self.navigationItem.largeTitleDisplayMode = .never
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(self.settingsButtonSelected))
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
    
    if let arViewController =  segue.destination as? ARViewController {
      self.arViewController = arViewController
    }
  }
  
  // MARK: - Actions
  
  @IBAction func addButtonSelected() {
    
    // Instantiate the add location view controller
    let currentLocation = LocationManager.shared.currentLocation
    let addLocationViewController = AddLocationViewController.newViewController(location: currentLocation, delegate: self)
    addLocationViewController.modalPresentationStyle = .popover
    addLocationViewController.popoverPresentationController?.delegate = self
    addLocationViewController.preferredContentSize = CGSize(width: self.view.bounds.width - 16, height: addLocationViewController.preferredContentHeight)
    addLocationViewController.popoverPresentationController?.sourceView = self.addButton
    addLocationViewController.popoverPresentationController?.sourceRect = self.addButton.bounds
    self.present(addLocationViewController, animated: true, completion: nil)
  }
  
  @IBAction func listButtonSelected() {
    
    // Instantiate the location list view controller
    let currentLocation = LocationManager.shared.currentLocation
    let locationListViewController = LocationListViewController.newViewController(currentLocation: currentLocation, delegate: self)
    locationListViewController.modalPresentationStyle = .popover
    locationListViewController.popoverPresentationController?.delegate = self
    locationListViewController.preferredContentSize = CGSize(width: self.view.bounds.width - 16, height: min(self.view.bounds.height, 300))
    locationListViewController.popoverPresentationController?.sourceView = self.listButton
    locationListViewController.popoverPresentationController?.sourceRect = self.listButton.bounds
    self.present(locationListViewController, animated: true, completion: nil)
  }
  
  @objc func settingsButtonSelected() {
    
  }
}

extension MainViewController : UIPopoverPresentationControllerDelegate {
  
  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
  }
}
