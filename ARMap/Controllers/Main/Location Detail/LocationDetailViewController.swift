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
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var colorChooserContainer: UIView!
  
  var savedLocation: SavedLocation? = nil
  var colorChooserController: InlineColorChooserViewController? = nil
  
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
    
    // Configure the color chooser
    if self.colorChooserController == nil {
      self.configureColorChooser()
    }
    
    // Update content
    self.reloadContent()
  }
  
  // MARK: - NSFetchedResultsControllerDelegate
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    if controller == self.savedLocationsFetchedResultsController {
      self.savedLocation = self.savedLocationsFetchedResultsController?.fetchedObjects?.first
      self.reloadContent()
    }
  }
  
  // MARK: - Color Chooser
  
  func configureColorChooser() {
    
    guard self.colorChooserController == nil else {
      return
    }
    
    let colorChooserController = InlineColorChooserViewController.newViewController(delegate: self)
    colorChooserController.view.backgroundColor = .clear
    self.add(childViewController: colorChooserController, intoContainerView: self.colorChooserContainer)
    self.colorChooserController = colorChooserController
  }
  
  // MARK: - Content
  
  func reloadContent() {
    
  }
  
  // MARK: - Actions
}

// MARK: - InlineColorChooserViewControllerDelegate

extension LocationDetailViewController : InlineColorChooserViewControllerDelegate {
  
  func didSelect(color: UIColor) {
    self.savedLocation?.color?.color = color
    MyDataManager.shared.saveMainContext()
  }
}
