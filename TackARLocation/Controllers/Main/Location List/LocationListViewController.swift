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
  func shouldDelete(location: SavedLocation)
}

class LocationListViewController : UIViewController, NSFetchedResultsControllerDelegate {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> LocationListViewController {
    return self.newViewController(fromStoryboardWithName: "Main")
  }
  
  static func newViewController(currentLocation: CLLocation?, delegate: LocationListViewControllerDelegate?) -> LocationListViewController {
    let viewController = self.newViewController()
    viewController.currentLocation = currentLocation
    viewController.delegate = delegate
    return viewController
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var tableView: UITableView!
  
  weak var delegate: LocationListViewControllerDelegate? = nil
  let rowHeight: CGFloat = 60
  
  var currentLocation: CLLocation? = nil {
    didSet {
      if self.isViewLoaded {
        self.reloadContent()
      }
    }
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

// MARK: - UITableViewDelegate, UITableViewDataSource

extension LocationListViewController : UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.savedLocations.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return self.rowHeight
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "LocationListViewControllerCell", for: indexPath) as! LocationListViewControllerCell
    cell.backgroundColor = .clear
    let savedLocation = self.savedLocations[indexPath.row]
    cell.titleLabel.text = savedLocation.name ?? "Unnamed"
    if let currentLocation = self.currentLocation {
      let saved = CLLocation(latitude: savedLocation.latitude, longitude: savedLocation.longitude)
      let distance = currentLocation.distance(from: saved)
      if Defaults.shared.unitType == .metric {
        cell.detailLabel.text = "\(Int(distance)) m away"
      } else {
        let feet = distance * 3.28084 // 1m == 3.28084ft
        cell.detailLabel.text = "\(Int(feet)) ft away"
      }
    } else {
      let roundedLatitude = Double(round(savedLocation.latitude*1000)/1000)
      let roundedLongitude = Double(round(savedLocation.longitude*1000)/1000)
      cell.detailLabel.text = "\(roundedLatitude)°N, \(roundedLongitude)°W"
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return .delete
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let savedLocation = self.savedLocations[indexPath.row]
      self.delegate?.shouldDelete(location: savedLocation)
    }
  }
}
