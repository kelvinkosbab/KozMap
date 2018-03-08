//
//  ModeChooserViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/7/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

enum AppMode {
  case myPlacemarks, foodNearby, mountainViewer
}

protocol ModeChooserDelegate : class {
  func didChooseMode(_ mode: AppMode, sender: PresentableController)
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
    self.delegate?.didChooseMode(.myPlacemarks, sender: self)
  }
  
  @IBAction func myPlacemarksInfoButtonSelected() {}
  
  @IBAction func foodNearMeButtonSelected() {
    self.delegate?.didChooseMode(.foodNearby, sender: self)
  }
  
  @IBAction func foodNearMeInfoButtonSelected() {}
  
  @IBAction func mountainViewerButtonSelected() {
    self.delegate?.didChooseMode(.mountainViewer, sender: self)
  }
  
  @IBAction func mountainViewerInfoButtonSelected() {}
}
