//
//  LocationDetailViewController.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 1/20/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import UIKit
import CoreData

class LocationDetailViewController : BaseViewController, NSFetchedResultsControllerDelegate {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> LocationDetailViewController {
    return self.newViewController(fromStoryboardWithName: "AddLocation")
  }
  
  static func newViewController(savedLocation: SavedLocation) -> LocationDetailViewController {
    let viewController = self.newViewController()
    viewController.savedLocation = savedLocation
    return viewController
  }
  
  // MARK: - Properties
  
  var savedLocation: SavedLocation? = nil
  
  private lazy var savedLocationsFetchedResultsController: NSFetchedResultsController<SavedLocation>? = {
    
    guard let savedLocation = self.savedLocation else {
      return nil
    }
    
    let controller = SavedLocation.newFetchedResultsController(savedLocation: savedLocation)
    controller.delegate = self
    try? controller.performFetch()
    return controller
  }()
  
  // MARK: - Lifecycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.reloadContent()
  }
  
  // MARK: - NSFetchedResultsControllerDelegate
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    if controller == self.savedLocationsFetchedResultsController {
      self.savedLocation = self.savedLocationsFetchedResultsController?.fetchedObjects?.first
      self.reloadContent()
    }
  }
  
  // MARK: - Content
  
  func reloadContent() {
    
  }
  
  // MARK: - Actions
}
