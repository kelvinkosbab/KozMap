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
  @IBOutlet weak var foodNearMeButton: UIButton!
  @IBOutlet weak var mountainViewerButton: UIButton!
  
  weak var delegate: ModeChooserDelegate? = nil
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = nil
    self.navigationItem.largeTitleDisplayMode = .never
    self.baseNavigationController?.navigationBarStyle = .transparent
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.closeButtonSelected))
    
    self.view.backgroundColor = .clear
  }
  
  // MARK: - Status Bar
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - Actions
  
  @objc func closeButtonSelected() {
    self.dismissController()
  }
  
  @IBAction func myPlacemarksButtonSelected() {
    self.delegate?.didChooseMode(.myPlacemarks, sender: self)
  }
  
  @IBAction func foodNearMeButtonSelected() {
    self.delegate?.didChooseMode(.foodNearby, sender: self)
  }
  
  @IBAction func mountainViewerButtonSelected() {
    self.delegate?.didChooseMode(.mountainViewer, sender: self)
  }
}
