//
//  SettingsViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit
import StoreKit
import CoreData

class SettingsViewController : BaseTableViewController, DesiredContentHeightDelegate, DismissInteractable, NSFetchedResultsControllerDelegate, PrivacyNavigationDelegate {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> SettingsViewController {
    let viewController = self.newViewController(fromStoryboardWithName: "Settings")
    viewController.preferredContentSize.height = viewController.desiredContentHeight
    return viewController
  }
  
  // MARK: - DesiredContentHeightDelegate
  
  var desiredContentHeight: CGFloat {
    return 490
  }
  
  // MARK: - DismissInteractable
  
  var dismissInteractiveViews: [UIView] {
    var views: [UIView] = []
    if let navigationBar = self.navigationController?.navigationBar {
      views.append(navigationBar)
    }
    return views
  }
  
  // MARK: - ScrollViewInteractiveSenderDelegate
  
  weak var scrollViewInteractiveReceiverDelegate: ScrollViewInteractiveReceiverDelegate?
  
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
  @IBOutlet weak var privacyLabel: UILabel!
  @IBOutlet weak var versionLabel: UILabel!
  @IBOutlet weak var companyLabel: UILabel!
  
  // MARK: - Defaults
  
  var defaults: Defaults {
    return self.defaultsFetchedResultsController.fetchedObjects?.first ?? Defaults.shared
  }
  
  private lazy var defaultsFetchedResultsController: NSFetchedResultsController<Defaults> = {
    let controller = Defaults.newFetchedResultsController()
    controller.delegate = self
    try? controller.performFetch()
    return controller
  }()
  
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
    
    if UIDevice.current.isPhone {
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icChevronDown"), style: .plain, target: self, action: #selector(self.closeButtonSelected))
    } else {
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(self.closeButtonSelected))
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Reload content
    self.reloadContent()
  }
  
  // MARK: - NSFetchedResultsControllerDelegate
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
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
    self.unitSelectLabel.text = self.defaults.unitType.string
    
    // Beam transparency
    let beamNodeTransparencyPercent = Int((1 - self.defaults.beamNodeTransparency) * 100)
    self.beamTransparencySelectLabel.text = "\(beamNodeTransparencyPercent)%"
    
    // Day text color
    let dayColor = self.defaults.dayTextColor
    if dayColor.isBlack {
      self.dayTextColorSelectLabel.text = "Black"
    } else if dayColor.isWhite {
      self.dayTextColorSelectLabel.text = "White"
    } else {
      self.dayTextColorSelectLabel.text = "Placemark's Color"
    }
    
    // Night text color
    let nightColor = self.defaults.nightTextColor
    if nightColor.isBlack {
      self.nightTextColorSelectLabel.text = "Black"
    } else if nightColor.isWhite {
      self.nightTextColorSelectLabel.text = "White"
    } else {
      self.nightTextColorSelectLabel.text = "Placemark's Color"
    }
    
    // Rate button
    self.rateLabel.text = "Rate \(BuildManager.shared.buildTarget.appName)"
    
    // Contact button
    self.contactLabel.text = "Give Feedback"
    
    // Privacy button
    self.privacyLabel.text = "Privacy"
    
    // Version
    self.versionLabel.text = "Version \(UIApplication.shared.versionString ?? "N/A")"
    
    // Company
    self.companyLabel.text = BuildManager.shared.buildTarget.companyName
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
      return .main([ .units, .beamTransparency, .dayTextColor, .nightTextColor, .rate, .feedback, .privacy, .info ])
    default:
      return nil
    }
  }
  
  // MARK: - RowType
  
  enum RowType {
    case units, beamTransparency, dayTextColor, nightTextColor, rate, feedback, privacy, info
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
  
  // MARK: - Navigation
  
  func presentItemChooser(mode: ItemChooserViewController.Mode, selectedItem: ItemChooserViewController.Item) {
    let viewController = ItemChooserViewController.newViewController(mode: mode, selectedItem: selectedItem, delegate: self)
    if UIDevice.current.isPhone {
      viewController.presentIn(self, withMode: .custom(.rightToLeftCurrentContext), options: [ .presentingViewControllerDelegate(self) ])
    } else {
      viewController.presentIn(self, withMode: .navStack, options: [ .presentingViewControllerDelegate(self) ])
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
      switch self.defaults.unitType {
      case .imperial:
        self.presentItemChooser(mode: .units, selectedItem: .imperial)
      case .metric:
        self.presentItemChooser(mode: .units, selectedItem: .metric)
      }
      
    case .beamTransparency:
      switch self.defaults.beamNodeTransparency {
      case ..<0.31:
        self.presentItemChooser(mode: .beamTransparency, selectedItem: .v30)
      case ..<0.41:
        self.presentItemChooser(mode: .beamTransparency, selectedItem: .v40)
      case ..<0.51:
        self.presentItemChooser(mode: .beamTransparency, selectedItem: .v50)
      case ..<0.61:
        self.presentItemChooser(mode: .beamTransparency, selectedItem: .v60)
      case ..<0.71:
        self.presentItemChooser(mode: .beamTransparency, selectedItem: .v70)
      case ..<0.81:
        self.presentItemChooser(mode: .beamTransparency, selectedItem: .v80)
      case ..<0.91:
        self.presentItemChooser(mode: .beamTransparency, selectedItem: .v90)
      default:
        self.presentItemChooser(mode: .beamTransparency, selectedItem: .v100)
      }
    case .dayTextColor:
      if self.defaults.dayTextColor.isBlack {
        self.presentItemChooser(mode: .dayTextColor, selectedItem: .black)
      } else if self.defaults.dayTextColor.isWhite {
        self.presentItemChooser(mode: .dayTextColor, selectedItem: .white)
      } else {
        self.presentItemChooser(mode: .dayTextColor, selectedItem: .placemarkColor)
      }
      
    case .nightTextColor:
      if self.defaults.nightTextColor.isBlack {
        self.presentItemChooser(mode: .nightTextColor, selectedItem: .black)
      } else if self.defaults.nightTextColor.isWhite {
        self.presentItemChooser(mode: .nightTextColor, selectedItem: .white)
      } else {
        self.presentItemChooser(mode: .nightTextColor, selectedItem: .placemarkColor)
      }
      
    case .rate:
      SKStoreReviewController.requestReview()
      
    case .feedback:
      if let url = URL(string: BuildManager.shared.buildTarget.giveFeedbackUrlString) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
      
    case .privacy:
      if UIDevice.current.isPhone {
        self.presentPrivacy(presentationMode: .custom(.rightToLeftCurrentContext), options: [ .presentingViewControllerDelegate(self) ])
      } else {
        self.presentPrivacy(presentationMode: .navStack, options: [ .presentingViewControllerDelegate(self) ])
      }
      
    case .info: break
    }
  }
}

// MARK: - ItemChooserViewControllerDelegate

extension SettingsViewController : ItemChooserViewControllerDelegate {
  
  func didChooseItem(_ item: ItemChooserViewController.Item, forMode mode: ItemChooserViewController.Mode, sender: ItemChooserViewController) {
    sender.dismissController()
    switch mode {
    case .units:
      switch item {
      case .imperial:
        self.defaults.unitType = .imperial
      case .metric:
        self.defaults.unitType = .metric
      default: break
      }
    case .beamTransparency:
      switch item {
      case .v30:
        self.defaults.beamNodeTransparency = 0.3
      case .v40:
        self.defaults.beamNodeTransparency = 0.4
      case .v50:
        self.defaults.beamNodeTransparency = 0.5
      case .v60:
        self.defaults.beamNodeTransparency = 0.6
      case .v70:
        self.defaults.beamNodeTransparency = 0.7
      case .v80:
        self.defaults.beamNodeTransparency = 0.8
      case .v90:
        self.defaults.beamNodeTransparency = 0.9
      case .v100:
        self.defaults.beamNodeTransparency = 1
      default: break
      }
    case .dayTextColor:
      switch item {
      case .black:
        self.defaults.dayTextColor = .black
      case .white:
        self.defaults.dayTextColor = .white
      case .placemarkColor:
        self.defaults.dayTextColor = .null
      default: break
      }
    case .nightTextColor:
      switch item {
      case .black:
        self.defaults.nightTextColor = .black
      case .white:
        self.defaults.nightTextColor = .white
      case .placemarkColor:
        self.defaults.nightTextColor = .null
      default: break
      }
    }
  }
}

// MARK: - PresentingViewControllerDelegate

extension SettingsViewController : PresentingViewControllerDelegate {
  
  func willPresentViewController(_ viewController: UIViewController) {}
  
  func isPresentingViewController(_ viewController: UIViewController?) {
    if let _ = (viewController as? UINavigationController)?.viewControllers.first ?? viewController as? ItemChooserViewController {
      self.navigationController?.navigationBar.alpha = 0
      self.view.alpha = 0
    }
  }
  
  func didPresentViewController(_ viewController: UIViewController?) {
    if let _ = (viewController as? UINavigationController)?.viewControllers.first ?? viewController as? ItemChooserViewController {
      self.navigationController?.navigationBar.alpha = 0
      self.view.alpha = 0
    }
  }
  
  func willDismissViewController(_ viewController: UIViewController) {}
  
  func isDismissingViewController(_ viewController: UIViewController?) {
    self.navigationController?.navigationBar.alpha = 1
    self.view.alpha = 1
  }
  
  func didDismissViewController(_ viewController: UIViewController?) {
    self.navigationController?.navigationBar.alpha = 1
    self.view.alpha = 1
  }
  
  func didCancelDissmissViewController(_ viewController: UIViewController?) {}
}

// MARK: - UIScrollView

extension SettingsViewController {
  
  override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.scrollViewInteractiveReceiverDelegate?.scrollViewWillBeginDragging(scrollView)
  }
  
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.scrollViewInteractiveReceiverDelegate?.scrollViewDidScroll(scrollView)
  }
  
  override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    self.scrollViewInteractiveReceiverDelegate?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
  }
}
