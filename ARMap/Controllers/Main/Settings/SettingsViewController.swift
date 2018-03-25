//
//  SettingsViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit
import StoreKit

class SettingsViewController : BaseTableViewController, DesiredContentHeightDelegate, DismissInteractable {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> SettingsViewController {
    let viewController = self.newViewController(fromStoryboardWithName: "Settings")
    viewController.preferredContentSize.height = viewController.desiredContentHeight
    return viewController
  }
  
  // MARK: - DesiredContentHeightDelegate
  
  var desiredContentHeight: CGFloat {
    return 440
  }
  
  // MARK: - DismissInteractable
  
  var dismissInteractiveViews: [UIView] {
    var views: [UIView] = []
    if let view = self.view {
      views.append(view)
    }
    if let navigationBar = self.navigationController?.navigationBar {
      views.append(navigationBar)
    }
    return views
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var unitLabel: UILabel!
  @IBOutlet weak var unitSelectLabel: UILabel!
  
  @IBOutlet weak var beamTransparencyLabel: UILabel!
  @IBOutlet weak var beamTransparencySelectLabel: UILabel!
  
  @IBOutlet weak var dayTextColorLabel: UILabel!
  @IBOutlet weak var dayTextColorSelectLabel: UILabel!
  
  @IBOutlet weak var nightTextColorLabel: UILabel!
  @IBOutlet weak var nightTextColorSelectLabel: UILabel!
  
  @IBOutlet weak var rateLabel: UILabel!
  @IBOutlet weak var contactLabel: UILabel!
  @IBOutlet weak var versionLabel: UILabel!
  @IBOutlet weak var companyLabel: UILabel!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Settings"
    
    self.navigationItem.largeTitleDisplayMode = UIDevice.current.isPhone ? .never : .always
    if UIDevice.current.isPhone {
      self.baseNavigationController?.navigationBarStyle = .transparentBlueTint
      self.view.backgroundColor = .clear
      self.tableView.backgroundColor = .clear
    } else {
      self.baseNavigationController?.navigationBarStyle = .standard
      self.view.backgroundColor = .white
      self.tableView.backgroundColor = .white
    }
    
    if !UIDevice.current.isPhone {
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(self.closeButtonSelected))
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Reload content
    self.reloadContent()
  }
  
  // MARK: - Status Bar
  
  override var prefersStatusBarHidden: Bool {
    return UIDevice.current.isPhone
  }
  
  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return .slide
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - Content
  
  func reloadContent() {
    
    // Unit type
    self.unitSelectLabel.text = Defaults.shared.unitType.string
    
    // Beam transparency
    let beamNodeTransparencyPercent = Int(Defaults.shared.beamNodeTransparency * 100)
    self.beamTransparencySelectLabel.text = "\(beamNodeTransparencyPercent)%"
    
    // Day text color
    let dayColor = Defaults.shared.dayTextColor
    if dayColor.isBlack {
      self.dayTextColorSelectLabel.text = "Black"
    } else if dayColor.isWhite {
      self.dayTextColorSelectLabel.text = "White"
    } else {
      self.dayTextColorSelectLabel.text = "Placemark's Color"
    }
    
    // Night text color
    let nightColor = Defaults.shared.nightTextColor
    if nightColor.isBlack {
      self.nightTextColorSelectLabel.text = "Black"
    } else if nightColor.isWhite {
      self.nightTextColorSelectLabel.text = "White"
    } else {
      self.nightTextColorSelectLabel.text = "Placemark's Color"
    }
    
    // Version
    self.versionLabel.text = "Version \(UIApplication.shared.versionString ?? "N/A")"
    
    // Company
    self.companyLabel.text = BuildManager.shared.buildTarget.companyName
    
    // Rate button
    self.rateLabel.text = "Rate \(BuildManager.shared.buildTarget.appName)"
    
    // Contact button
    self.contactLabel.text = "Give Feedback"
  }
  
  // MARK: - Actions
  
  @objc func closeButtonSelected() {
    self.dismissController()
  }
  
  // MARK: - SectionType
  
  enum SectionType {
    case main([RowType])
  }
  
  func getSectionType(section: Int) -> SectionType? {
    switch section {
    case 0:
      return .main([ .units, .beamTransparency, .dayTextColor, .nightTextColor, .rate, .feedback, .info ])
    default:
      return nil
    }
  }
  
  // MARK: - RowType
  
  enum RowType {
    case units, beamTransparency, dayTextColor, nightTextColor, rate, feedback, info
  }
  
  func getRowType(at indexPath: IndexPath) -> RowType? {
    
    guard let sectionType = self.getSectionType(section: indexPath.section) else {
      return nil
    }
    
    switch sectionType {
    case .main(let rowTypes):
      if indexPath.row < rowTypes.count {
        let rowType = rowTypes[indexPath.row]
        return rowType
      }
      return nil
    }
  }
  
  // MARK: - UITableView
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    cell.backgroundColor = .clear
    cell.contentView.backgroundColor = .clear
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    guard let rowType = self.getRowType(at: indexPath) else {
      return
    }
    
    switch rowType {
    case .units:
      /*
       switch control {
       case self.unitTypeControl:
       if let unitType = UnitType(rawValue: control.selectedSegmentIndex) {
       Defaults.shared.unitType = unitType
       MyDataManager.shared.saveMainContext()
       }
       default: break
       }*/
      break
      
    case .beamTransparency: break
    case .dayTextColor: break
    case .nightTextColor: break
      
    case .rate:
      SKStoreReviewController.requestReview()
      
    case .feedback:
      if let url = URL(string: BuildManager.shared.buildTarget.giveFeedbackUrlString) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
      
    case .info: break
    }
  }
}
