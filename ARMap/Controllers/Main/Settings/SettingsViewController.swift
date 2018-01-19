//
//  SettingsViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

class SettingsViewController : BaseViewController, DesiredContentHeightDelegate {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> SettingsViewController {
    return self.newViewController(fromStoryboardWithName: "Main")
  }
  
  // MARK: - DesiredContentHeightDelegate
  
  var desiredContentHeight: CGFloat {
    return 250
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var settingsLabel: UILabel!
  @IBOutlet weak var unitLabel: UILabel!
  @IBOutlet weak var unitTypeControl: UISegmentedControl!
  @IBOutlet weak var versionLabel: UILabel!
  @IBOutlet weak var companyLabel: UILabel!
  
  // MARK: - Lifecycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Reload content
    self.reloadContent()
  }
  
  // MARK: - Content
  
  func reloadContent() {
    
    // Unit type
    self.unitTypeControl.selectedSegmentIndex = Defaults.shared.unitType.rawValue
    
    // Version
    self.versionLabel.text = "Version \(UIApplication.shared.versionString ?? "N/A")"
  }
  
  // MARK: - Actions
  
  @IBAction func segmentedControlValueChanged(_ control: UISegmentedControl) {
    switch control {
    case self.unitTypeControl:
      if let unitType = UnitType(rawValue: control.selectedSegmentIndex) {
        Defaults.shared.unitType = unitType
        MyDataManager.shared.saveMainContext()
      }
    default: break
    }
  }
  
  @IBAction func walkthroughButtonSelected() {
    
  }
}
