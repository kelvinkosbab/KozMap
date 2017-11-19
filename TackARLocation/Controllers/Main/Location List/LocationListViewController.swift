//
//  LocationListViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
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
  
  var currentLocation: CLLocation? {
    return LocationManager.shared.currentLocation
  }
  
  var savedLocations: [SavedLocation] {
    return self.savedLocationsFetchedResultsController?.fetchedObjects ?? []
  }
  
  private lazy var savedLocationsFetchedResultsController: NSFetchedResultsController<SavedLocation>? = {
    let controller = SavedLocation.newFetchedResultsController()
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveUpdatedLocationNotification(_:)), name: .locationManagerDidUpdateCurrentLocation, object: nil)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Notifications
  
  @objc func didReceiveUpdatedLocationNotification(_ notification: Notification) {
    self.reloadContent()
  }
  
  // MARK: - NSFetchedResultsControllerDelegate
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    self.tableView.beginUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      if let newIndexPath = newIndexPath {
        self.tableView.insertRows(at: [ newIndexPath ], with: .automatic)
      } else {
        self.tableView.reloadData()
      }
      
    case .delete:
      if let indexPath = indexPath {
        self.tableView.deleteRows(at: [ indexPath ], with: .automatic)
      } else {
        self.tableView.reloadData()
      }
      
    case .update:
      if let indexPath = indexPath {
        self.tableView.reloadRows(at: [ indexPath ], with: .none)
      } else {
        self.tableView.reloadData()
      }
      
    case .move:
      if let indexPath = indexPath, let newIndexPath = newIndexPath {
        self.tableView.deleteRows(at: [ indexPath ], with: .automatic)
        self.tableView.insertRows(at: [ newIndexPath ], with: .automatic)
      } else {
        self.tableView.reloadData()
      }
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    self.tableView.endUpdates()
  }
  
  // MARK: - Content
  
  func reloadContent() {
    self.tableView.reloadData()
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
    cell.titleLabel.text = savedLocation.name ?? "Unnamed"
    
    // Distance labels
    if let currentLocation = self.currentLocation {
      let distance = currentLocation.distance(from: savedLocation.location)
      let readibleDistance = distance.getBasicReadibleDistance(nearUnitType: Defaults.shared.nearUnitType, farUnitType: Defaults.shared.farUnitType)
      cell.detailLabel.text = "\(readibleDistance) away"
    } else {
      let roundedLatitude = Double(round(savedLocation.latitude*1000)/1000)
      let roundedLongitude = Double(round(savedLocation.longitude*1000)/1000)
      cell.detailLabel.text = "\(roundedLatitude)°N, \(roundedLongitude)°W"
    }
    
    // Color view
    if let color = savedLocation.color {
      cell.colorView.backgroundColor = color.color
    } else {
      cell.colorView.backgroundColor = .kozRed
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let savedLocation = self.savedLocations[indexPath.row]
    let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, success) in
      self?.delegate?.shouldEdit(savedLocation: savedLocation)
      success(true)
    }
    editAction.backgroundColor = .kozBlue
    return UISwipeActionsConfiguration(actions: [ editAction ])
  }
  
  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let savedLocation = self.savedLocations[indexPath.row]
    let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, success) in
      self?.delegate?.shouldDelete(savedLocation: savedLocation)
      success(true)
    }
    deleteAction.backgroundColor = .kozRed
    return UISwipeActionsConfiguration(actions: [ deleteAction ])
  }
}
