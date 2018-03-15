//
//  ModeChooserViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/7/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

protocol ModeChooserDelegate : class {
  func didChooseMode(_ appMode: AppMode, sender: UIViewController)
}

class ModeChooserViewController : BaseViewController {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> ModeChooserViewController {
    return self.newViewController(fromStoryboardWithName: "ModeChooser")
  }
  
  static func newViewController(delegate: ModeChooserDelegate?) -> ModeChooserViewController {
    let viewController = self.newViewController()
    viewController.delegate = delegate
    return viewController
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var myPlacemarksButton: UIButton!
  @IBOutlet weak var myPlacemarksInfoButton: UIButton!
  @IBOutlet weak var foodNearMeButton: UIButton!
  @IBOutlet weak var foodNearMeInfoButton: UIButton!
  @IBOutlet weak var mountainViewerButton: UIButton!
  @IBOutlet weak var mountainViewerInfoButton: UIButton!
  @IBOutlet weak var arrowDownButton: UIButton!
  
  weak var delegate: ModeChooserDelegate? = nil
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = nil
    self.navigationItem.largeTitleDisplayMode = .never
    self.baseNavigationController?.navigationBarStyle = .transparent
    
    self.view.backgroundColor = .clear
  }
  
  // MARK: - Status Bar
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - Actions
  
  @IBAction func arrowDownButtonSelected() {
    self.dismissController()
  }
  
  @IBAction func myPlacemarksButtonSelected() {
    self.delegate?.didChooseMode(.myPlacemark, sender: self)
  }
  
  @IBAction func myPlacemarksInfoButtonSelected() {
    let title = NSLocalizedString("Your Placemarks", comment: "Your Placemarks")
    let message = NSLocalizedString("Add Placemarks that are important to you. These Placemarks are then saved and visible to you. Included in the Placemark details is the address and the phone number if you added from search.", comment: "Your Placemarks description text")
    self.presentOkAlert(title: title, message: message)
  }
  
  @IBAction func foodNearMeButtonSelected() {
    self.delegate?.didChooseMode(.food, sender: self)
  }
  
  @IBAction func foodNearMeInfoButtonSelected() {
    let title = NSLocalizedString("Restaurants Nearby", comment: "Restaurants Nearby")
    let message = NSLocalizedString("Discover Restaurants Nearby and add your favorite places to eat! Ten resaurants are automatically visiable in your current area. Looking for a specific kind of restaurant? Simply search and the visible restaurants will be updated. Your favorites will always be visible regardless to what you are searching for.", comment: "Restaurants Nearby description text")
    self.presentOkAlert(title: title, message: message)
  }
  
  @IBAction func mountainViewerButtonSelected() {
    self.delegate?.didChooseMode(.mountain, sender: self)
  }
  
  @IBAction func mountainViewerInfoButtonSelected() {
    let title = NSLocalizedString("Mountain Viewer", comment: "Mountain Viewer")
    let message = NSLocalizedString("View significant Mountains in your region and access general information as well as information for visiting and conquering these peaks.\n(Currently only supported for the Colorado Front Range)", comment: "Mountain Viewer description text")
    self.presentOkAlert(title: title, message: message)
  }
}
