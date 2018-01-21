//
//  LocationDetailViewController.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 1/20/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import UIKit
import CoreData

class LocationDetailViewController : BaseViewController, NSFetchedResultsControllerDelegate, DesiredContentHeightDelegate {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> LocationDetailViewController {
    return self.newViewController(fromStoryboardWithName: "AddLocation")
  }
  
  static func newViewController(savedLocation: SavedLocation) -> LocationDetailViewController {
    let viewController = self.newViewController()
    viewController.savedLocation = savedLocation
    return viewController
  }
  
  // MARK: - DesiredContentHeightDelegate
  
  var desiredContentHeight: CGFloat {
    return 271
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var locationDescriptionLabel: UILabel!
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
    
    // UITextFieldDelegate
    self.nameTextField.delegate = self
    
    // Update content
    self.reloadContent()
    
    // Listen for updates to current location
    NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveUpdatedLocationNotification(_:)), name: .locationManagerDidUpdateCurrentLocation, object: nil)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    MyDataManager.shared.saveMainContext()
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Notifications
  
  @objc func didReceiveUpdatedLocationNotification(_ notification: Notification) {
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
    
    // Check if there is a location to populate
    guard let savedLocation = self.savedLocation else {
      self.latitudeLabel.text = "NA"
      self.longitudeLabel.text = "NA"
      self.distanceLabel.text = "NA"
      self.locationDescriptionLabel.text = ""
      return
    }
    
    // Name
    self.nameTextField.text = savedLocation.name
    
    // Color
    if let color = savedLocation.color?.color {
      self.colorChooserController?.selectedColor = color
    }
    
    // Update the current location
    let location = savedLocation.location
    let coordinate = location.coordinate
    let roundedLatitude = Double(round(coordinate.latitude*1000)/1000)
    let roundedLongitude = Double(round(coordinate.longitude*1000)/1000)
    self.latitudeLabel.text = "\(roundedLatitude)"
    self.longitudeLabel.text = "\(roundedLongitude)"
    
    // Update the distance
    let currentLocation = LocationManager.shared.currentLocation
    let distance = currentLocation?.distance(from: location)
    self.distanceLabel.text = distance?.getDistanceString(unitType: Defaults.shared.unitType, displayType: .numbericUnits(false)) ?? "NA"
    
    // Location address
    self.locationDescriptionLabel.text = savedLocation.address
    location.getPlacemark { [weak self] placemark in
      self?.locationDescriptionLabel.text = placemark?.address
    }
  }
  
  // MARK: - Actions
  
  @IBAction func nameTextFieldEditingChanged(_ sender: UITextField) {
    self.savedLocation?.name = sender.text
  }
}

// MARK: - InlineColorChooserViewControllerDelegate

extension LocationDetailViewController : InlineColorChooserViewControllerDelegate {
  
  func didSelect(color: UIColor) {
    self.savedLocation?.color?.color = color
  }
}

// MARK: - UITextFieldDelegate

extension LocationDetailViewController : UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    if let _ = textField.text {
      return true
    }
    return false
  }
}
