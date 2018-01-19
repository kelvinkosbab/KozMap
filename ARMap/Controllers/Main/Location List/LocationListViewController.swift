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
  func shouldEdit(savedLocation: SavedLocation)
  func shouldDelete(savedLocation: SavedLocation)
}

class LocationListViewController : BaseTableViewController, NSFetchedResultsControllerDelegate {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> LocationListViewController {
    return self.newViewController(fromStoryboardWithName: "AddLocation")
  }
  
  static func newViewController(delegate: LocationListViewControllerDelegate?) -> LocationListViewController {
    let viewController = self.newViewController()
    viewController.delegate = delegate
    return viewController
  }
  
  // MARK: - Properties
  
  weak var delegate: LocationListViewControllerDelegate? = nil
  let rowHeight: CGFloat = 60
  
  var savedLocations: [SavedLocation] {
    return self.savedLocationsFetchedResultsController?.fetchedObjects ?? []
  }
  
  private lazy var savedLocationsFetchedResultsController: NSFetchedResultsController<SavedLocation>? = {
    let controller = SavedLocation.newFetchedResultsController()
    controller.delegate = self
    try? controller.performFetch()
    return controller
  }()
  
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
          let savedLocation = self.savedLocations[indexPath.row]
          cell.configure(savedLocation: savedLocation, unitType: Defaults.shared.unitType, delegate: self)
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

extension LocationListViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.savedLocations.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return self.rowHeight
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "LocationListViewControllerCell", for: indexPath) as! LocationListViewControllerCell
    cell.backgroundColor = .clear
    
    // Saved location
    let savedLocation = self.savedLocations[indexPath.row]
    cell.configure(savedLocation: savedLocation, unitType: Defaults.shared.unitType, delegate: self)
    
    return cell
  }
}

// MARK: - LocationListViewControllerCellDelegate

extension LocationListViewController : LocationListViewControllerCellDelegate {
  
  func moreButtonSelected(savedLocation: SavedLocation, sender: UIView) {
    self.presentMoreActionSheet(savedLocation: savedLocation, sender: sender)
  }
  
  private func presentMoreActionSheet(savedLocation: SavedLocation, sender: UIView) {
    let actionSheet = UIAlertController(title: savedLocation.name, message: nil, preferredStyle: .actionSheet)
    
    // Edit
    let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
      self?.delegate?.shouldEdit(savedLocation: savedLocation)
    }
    actionSheet.addAction(editAction)
    
    // Delete
    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
      self?.delegate?.shouldDelete(savedLocation: savedLocation)
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
