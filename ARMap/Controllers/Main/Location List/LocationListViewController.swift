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
  func shouldDelete(placemark: Placemark)
}

class LocationListViewController : BaseViewController, NSFetchedResultsControllerDelegate, DesiredContentHeightDelegate, DismissInteractable {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> LocationListViewController {
    let viewController = self.newViewController(fromStoryboardWithName: "AddLocation")
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
    return 450
  }
  
  // MARK: - DismissInteractable
  
  var dismissInteractiveView: UIView? {
    return self.tableView
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var tableView: UITableView!
  
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
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
  }
  
  // MARK: - Status Bar
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return .slide
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
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
          cell.configure(placemark: placemark, unitType: Defaults.shared.unitType, delegate: self)
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
}

// MARK: - UITableView

extension LocationListViewController : UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.placemarks.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return self.rowHeight
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "LocationListViewControllerCell", for: indexPath) as! LocationListViewControllerCell
    cell.backgroundColor = .clear
    
    // Saved location
    let placemark = self.placemarks[indexPath.row]
    cell.configure(placemark: placemark, unitType: Defaults.shared.unitType, delegate: self)
    
    return cell
  }
}

// MARK: - LocationListViewControllerCellDelegate

extension LocationListViewController : LocationListViewControllerCellDelegate {
  
  func moreButtonSelected(placemark: Placemark, sender: UIView) {
    self.presentMoreActionSheet(placemark: placemark, sender: sender)
  }
  
  private func presentMoreActionSheet(placemark: Placemark, sender: UIView) {
    let actionSheet = UIAlertController(title: placemark.name, message: nil, preferredStyle: .actionSheet)
    
    // Edit
    let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
      self?.delegate?.shouldEdit(placemark: placemark)
    }
    actionSheet.addAction(editAction)
    
    // Delete
    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
      self?.delegate?.shouldDelete(placemark: placemark)
    }
    actionSheet.addAction(deleteAction)
    
    // Cancel
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    actionSheet.addAction(cancelAction)
    
    if UIDevice.current.isPhone {
      self.present(actionSheet, animated: true, completion: nil)
    } else {
      actionSheet.modalPresentationStyle = .popover
      actionSheet.popoverPresentationController?.sourceView = sender
      actionSheet.popoverPresentationController?.sourceRect = sender.frame
      self.present(actionSheet, animated: true, completion: nil)
    }
  }
}
