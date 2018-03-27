//
//  ItemChooserViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/25/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

protocol ItemChooserViewControllerDelegate : class {
  func didChooseItem(_ item: ItemChooserViewController.Item, forMode mode: ItemChooserViewController.Mode, sender: ItemChooserViewController)
}

class ItemChooserViewController : BaseTableViewController, DismissInteractable {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> ItemChooserViewController {
    return self.newViewController(fromStoryboardWithName: "ItemChooser")
  }
  
  static func newViewController(mode: ItemChooserViewController.Mode, selectedItem: ItemChooserViewController.Item?, delegate: ItemChooserViewControllerDelegate?) -> ItemChooserViewController {
    let viewController = self.newViewController()
    viewController.mode = mode
    viewController.selectedItem = selectedItem
    viewController.delegate = delegate
    return viewController
  }
  
  // MARK: - DismissInteractable
  
  var dismissInteractiveViews: [UIView] {
    var views: [UIView] = []
    if let view = self.view {
      views.append(view)
    }
    return views
  }
  
  // MARK: - Mode / Item
  
  enum Mode {
    case units, beamTransparency, dayTextColor, nightTextColor
    
    var items: [Item] {
      switch self {
      case .units:
        return [ .imperial, .metric ]
      case .beamTransparency:
        return [ .v30, .v40, .v50, .v60, .v70, .v80, .v90, .v100 ]
      case .dayTextColor, .nightTextColor:
        return [ .black, .white, .placemarkColor ]
      }
    }
  }
  
  enum Item {
    case imperial, metric
    case black, white, placemarkColor
    case v30, v40, v50, v60, v70, v80, v90, v100
    
    var string: String {
      switch self {
      case .imperial:
        return "Imperial"
      case .metric:
        return "Metric"
      case .black:
        return "Black Text Color"
      case .white:
        return "White Text Color"
      case .placemarkColor:
        return "Placemark Color"
      case .v30:
        return "70% Transparent"
      case .v40:
        return "60% Transparent"
      case .v50:
        return "50% Transparent"
      case .v60:
        return "40% Transparent"
      case .v70:
        return "30% Transparent"
      case .v80:
        return "20% Transparent"
      case .v90:
        return "10% Transparent"
      case .v100:
        return "Solid Color"
      }
    }
  }
  
  // MARK: - Properties
  
  var mode: Mode = .units
  weak var delegate: ItemChooserViewControllerDelegate? = nil
  var selectedItem: Item? = nil
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Title
    switch mode {
    case .units:
      self.title = "Unit Type"
    case .beamTransparency:
      self.title = "Unit Type"
    case .dayTextColor:
      self.title = "Day Text Color"
    case .nightTextColor:
      self.title = "Night Text Color"
    }
    
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
    
    // Back button
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: LocalizedString.cancel, style: .plain, target: self, action: #selector(self.backButtonSelected))
  }
  
  // MARK: - SectionType
  
  enum SectionType {
    case items([Item])
  }
  
  func getSectionType(section: Int) -> SectionType? {
    switch section {
    case 0:
      return .items(self.mode.items)
    default:
      return nil
    }
  }
  
  // MARK: - RowType
  
  enum RowType {
    case item(Item)
  }
  
  func getRowType(at indexPath: IndexPath) -> RowType? {
    
    guard let sectionType = self.getSectionType(section: indexPath.section) else {
      return nil
    }
    
    switch sectionType {
    case .items(let items):
      if indexPath.row < items.count {
        let item = items[indexPath.row]
        return .item(item)
      }
      return nil
    }
  }
  
  // MARK: - Actions
  
  @objc func backButtonSelected() {
    self.dismissController()
  }
  
  // MARK: - UITableView
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    guard let sectionType = self.getSectionType(section: section) else {
      return 0
    }
    
    switch sectionType {
    case .items(let items):
      return items.count
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ItemChooserViewControllerCell.name, for: indexPath) as! ItemChooserViewControllerCell
    cell.backgroundColor = .clear
    cell.contentView.backgroundColor = .clear
    
    guard let rowType = self.getRowType(at: indexPath) else {
      cell.titleLabel.text = nil
      return cell
    }
    
    switch rowType {
    case .item(let item):
      cell.titleLabel.text = item.string
      let selectedImage = item == self.selectedItem ? #imageLiteral(resourceName: "assetCheck") : nil
      cell.selectedImageView.image = selectedImage?.withRenderingMode(.alwaysTemplate)
      cell.selectedImageView.tintColor = .kozBlue
      return cell
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    guard let rowType = self.getRowType(at: indexPath) else {
      return
    }
    
    switch rowType {
    case .item(let item):
      self.delegate?.didChooseItem(item, forMode: self.mode, sender: self)
    }
  }
}

// MARK: - ItemChooserViewControllerCell

class ItemChooserViewControllerCell : UITableViewCell, ClassNamable {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var selectedImageView: UIImageView!
}
