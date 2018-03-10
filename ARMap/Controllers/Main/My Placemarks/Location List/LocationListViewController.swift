//
//  LocationListViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

protocol LocationListViewControllerDelegate : class {
  func shouldEdit(placemark: Placemark)
  func shouldTransitionToAddPlacemark()
}

class LocationListViewController : BaseTableViewController, NSFetchedResultsControllerDelegate, DesiredContentHeightDelegate, DismissInteractable, PlacemarkAPIDelegate, MyPlacemarksNavigationDelegate {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> LocationListViewController {
    let viewController = self.newViewController(fromStoryboardWithName: "LocationList")
    viewController.preferredContentSize.height = viewController.desiredContentHeight
    return viewController
  }
  
  static func newViewController(delegate: LocationListViewControllerDelegate?) -> LocationListViewController {
    let viewController = self.newViewController()
    viewController.delegate = delegate
    return viewController
  }
  
  // MARK: - DesiredContentHeightDelegate
  
  var desiredContentHeight: CGFloat {
    let totalPlacemarks = Placemark.countAll()
    let requiredTableHeight = CGFloat(totalPlacemarks) * self.rowHeight
    let padding: CGFloat = 50
    return requiredTableHeight + padding
  }
  
  // MARK: - DismissInteractable
  
  var dismissInteractiveViews: [UIView] {
    var views: [UIView] = []
    if let view = self.view {
      views.append(view)
    }
    if let tableView = self.tableView {
      views.append(tableView)
    }
    if let navigationBar = self.navigationController?.navigationBar {
      views.append(navigationBar)
    }
    return views
  }
  
  // MARK: - Properties
  
  weak var delegate: LocationListViewControllerDelegate? = nil
  let rowHeight: CGFloat = 60
  
  var placemarks: [Placemark] {
    return self.placemarksFetchedResultsController?.fetchedObjects ?? []
  }
  
  private lazy var placemarksFetchedResultsController: NSFetchedResultsController<Placemark>? = {
    let controller = Placemark.newFetchedResultsController()
    controller.delegate = self
    try? controller.performFetch()
    return controller
  }()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "My Placemarks"
    
    self.navigationItem.largeTitleDisplayMode = .never
    if UIDevice.current.isPhone {
      self.baseNavigationController?.navigationBarStyle = .transparentBlueTint
      self.view.backgroundColor = .clear
    } else {
      self.baseNavigationController?.navigationBarStyle = .standard
      self.view.backgroundColor = .white
    }
    
    // Navigation items
    if !UIDevice.current.isPhone {
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(self.closeButtonSelected))
    }
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonSelected))
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
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
  
  // MARK: - Actions
  
  func reloadContent() {
    self.tableView.reloadData()
  }
  
  @objc func closeButtonSelected() {
    self.dismissController()
  }
  
  @objc func addButtonSelected() {
    self.delegate?.shouldTransitionToAddPlacemark()
  }
  
  // MARK: - NSFetchedResultsControllerDelegate
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    self.tableView.beginUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      if let newIndexPath = newIndexPath {
        self.tableView.insertRows(at: [ newIndexPath ], with: .top)
      }
    case .delete:
      if let indexPath = indexPath {
        self.tableView.deleteRows(at: [ indexPath ], with: .top)
      }
    case .update:
      if let indexPath = indexPath {
        if let cell = self.tableView.cellForRow(at: indexPath) as? LocationListViewControllerCell {
          let placemark = self.placemarks[indexPath.row]
          cell.configure(placemark: placemark, unitType: Defaults.shared.unitType, delegate: self, hideMoreButton: !UIDevice.current.isPhone)
        } else {
          self.tableView.reloadRows(at: [ indexPath ], with: .none)
        }
      }
    case .move:
      if let indexPath = indexPath, let newIndexPath = newIndexPath {
        self.tableView.deleteRows(at: [ indexPath ], with: .top)
        self.tableView.insertRows(at: [ newIndexPath ], with: .top)
      }
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    self.tableView.endUpdates()
  }
  
  // MARK: - Navigation
  
  func transitionToDetail(placemark: Placemark) {
    if UIDevice.current.isPhone {
      self.delegate?.shouldEdit(placemark: placemark)
    } else {
      self.pushLocationDetail(placemark: placemark)
    }
  }
}

// MARK: - SectionType / RowType

extension LocationListViewController {
  
  enum SectionType {
    case placemarks([Placemark])
  }
  
  func getSectionType(section: Int) -> SectionType? {
    switch section {
    case 0:
      let placemarks = self.placemarks
      return .placemarks(placemarks)
    default:
      return nil
    }
  }
  
  enum RowType {
    case placemark(Placemark)
  }
  
  func getRowType(at indexPath: IndexPath) -> RowType? {
    
    guard let sectionType = self.getSectionType(section: indexPath.section) else {
      return nil
    }
    
    switch sectionType {
    case .placemarks(let placemarks):
      if indexPath.row < placemarks.count {
        let placemark = placemarks[indexPath.row]
        return .placemark(placemark)
      }
      return nil
    }
  }
}

// MARK: - UITableView

extension LocationListViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    guard let sectionType = self.getSectionType(section: section) else {
      return 0
    }
    
    switch sectionType {
    case .placemarks(let placemarks):
      return placemarks.count
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return self.rowHeight
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let rowType = self.getRowType(at: indexPath) else {
      let cell = UITableViewCell()
      cell.backgroundColor = tableView.backgroundColor
      return cell
    }
    
    switch rowType {
    case .placemark(let placemark):
      let cell = tableView.dequeueReusableCell(withIdentifier: LocationListViewControllerCell.name, for: indexPath) as! LocationListViewControllerCell
      cell.backgroundColor = .clear
      cell.configure(placemark: placemark, unitType: Defaults.shared.unitType, delegate: self, hideMoreButton: !UIDevice.current.isPhone)
      return cell
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard let rowType = self.getRowType(at: indexPath) else {
      return
    }
    
    // Check for phone vs pad
    guard !UIDevice.current.isPhone else {
      return
    }
    
    switch rowType {
    case .placemark(let placemark):
      self.transitionToDetail(placemark: placemark)
    }
  }
}

// MARK: - LocationListViewControllerCellDelegate

extension LocationListViewController : LocationListViewControllerCellDelegate {
  
  func moreButtonSelected(placemark: Placemark, sender: UIView) {
    self.presentMoreActionSheet(placemark: placemark, sender: sender)
  }
  
  private func presentMoreActionSheet(placemark: Placemark, sender: UIView) {
    let alertController = UIAlertController(title: placemark.name, message: nil, preferredStyle: UIDevice.current.isPhone ? .actionSheet : .alert)
    
    // Edit
    let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
      self?.transitionToDetail(placemark: placemark)
    }
    alertController.addAction(editAction)
    
    // Delete
    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
      self?.promptDeletePlacemark(placemark: placemark)
    }
    alertController.addAction(deleteAction)
    
    // Cancel
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    // Present the alert controller
    if UIDevice.current.isPhone {
      self.present(alertController, animated: true, completion: nil)
    } else {
      alertController.modalPresentationStyle = .popover
      alertController.popoverPresentationController?.sourceView = sender
      alertController.popoverPresentationController?.sourceRect = sender.frame
      self.present(alertController, animated: true, completion: nil)
    }
  }
}
