//
//  LocationDetailViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationDetailViewControllerDelegate : class {
  func didSave(savedLocation: SavedLocation)
  func didUpdate(savedLocation: SavedLocation)
}

class LocationDetailViewController : BaseViewController, DesiredContentHeightDelegate {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> LocationDetailViewController {
    return self.newViewController(fromStoryboardWithName: "AddLocation")
  }
  
  static func newViewController(delegate: LocationDetailViewControllerDelegate?) -> LocationDetailViewController {
    let viewController = self.newViewController()
    viewController.delegate = delegate
    return viewController
  }
  
  static func newViewController(savedLocation: SavedLocation, delegate: LocationDetailViewControllerDelegate?) -> LocationDetailViewController {
    let viewController = self.newViewController()
    viewController.savedLocation = savedLocation
    viewController.location = savedLocation.location
    if let color = savedLocation.color {
      viewController.locationColor = color.color
    }
    viewController.delegate = delegate
    return viewController
  }
  
  static func newViewController(mapItem: MapItem, delegate: LocationDetailViewControllerDelegate?) -> LocationDetailViewController {
    let viewController = self.newViewController()
    viewController.mapItem = mapItem
    viewController.location = mapItem.placemark.location
    viewController.delegate = delegate
    return viewController
  }
  
  // MARK: - DesiredContentHeightDelegate
  
  var desiredContentHeight: CGFloat {
    return 295
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addLocationButton: UIButton!
  @IBOutlet weak var colorChooserContainer: UIView!
  
  weak var delegate: LocationDetailViewControllerDelegate? = nil
  weak var colorChooserController: InlineColorChooserViewController? = nil
  
  var savedLocation: SavedLocation? = nil
  var mapItem: MapItem? = nil
  var locationColor: UIColor = .kozRed
  var location: CLLocation? = nil {
    didSet {
      if self.isViewLoaded && self.state == .creating {
        self.reloadContent()
      }
    }
  }
  
  enum LocationDetailState {
    case creating, updatingSavedLocation, creatingMapItem
  }
  
  var state: LocationDetailState {
    if self.savedLocation == nil && self.mapItem == nil {
      return .creating
    } else if let _ = self.savedLocation {
      return .updatingSavedLocation
    }
    return .creatingMapItem
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.nameTextField.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Configure the color chooser
    if self.colorChooserController == nil {
      self.configureColorChooser()
    }
    
    // Style button
    self.addLocationButton.layer.cornerRadius = 5
    self.addLocationButton.layer.masksToBounds = true
    self.addLocationButton.clipsToBounds = true
    
    // Content
    self.reloadContent()
    
    // Location updates
    if self.state == .creating {
      self.location = LocationManager.shared.currentLocation
      NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveUpdatedLocationNotification(_:)), name: .locationManagerDidUpdateCurrentLocation, object: nil)
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Notifications
  
  @objc func didReceiveUpdatedLocationNotification(_ notification: Notification) {
    if self.state == .creating {
      self.location = LocationManager.shared.currentLocation
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
    if self.state == .creating || self.state == .creatingMapItem {
      self.locationColor = .kozRed
      colorChooserController.selectedColor = .kozRed
    } else {
      if let selectedColor = self.savedLocation?.color {
        self.locationColor = selectedColor.color
        colorChooserController.selectedColor = selectedColor.color
      }
    }
  }
  
  // MARK: - Content
  
  func reloadContent() {
    
    // Saved location
    if let savedLocation = self.savedLocation {
      self.nameTextField.text = savedLocation.name
      self.location = savedLocation.location
    }
    
    // Map Item
    if let mapItem = self.mapItem {
      self.nameTextField.text = mapItem.name
      self.location = mapItem.placemark.location
    }
    
    // Check if there is a location to populate
    guard let location = self.location else {
      self.addLocationButton.isUserInteractionEnabled = false
      self.addLocationButton.alpha = 0.5
      self.latitudeLabel.text = "NA"
      self.longitudeLabel.text = "NA"
      return
    }
    
    // Update the current location
    self.addLocationButton.isUserInteractionEnabled = true
    self.addLocationButton.alpha = 1
    let coordinate = location.coordinate
    let roundedLatitude = Double(round(coordinate.latitude*1000)/1000)
    let roundedLongitude = Double(round(coordinate.longitude*1000)/1000)
    self.latitudeLabel.text = "\(roundedLatitude)"
    self.longitudeLabel.text = "\(roundedLongitude)"
  }
  
  // MARK: - Actions
  
  @IBAction func addLocationButtonSelected() {
    self.saveLocation()
  }
  
  func saveLocation() {
    
    // Check for valid location
    guard let location = self.location else {
      return
    }
    
    // Check for valid name
    guard let name = self.nameTextField.text?.trimmed, !name.isEmpty else {
      return
    }
    
    // Dismiss the keyboard
    self.nameTextField.resignFirstResponder()
    
    // Color of the saved location
    let color = self.savedLocation?.color ?? Color.create()
    color.color = self.locationColor
    
    // Distance
    let currentLocation = LocationManager.shared.currentLocation
    let distance = currentLocation?.distance(from: location)
    
    // Save the location
    if let savedLocation = self.savedLocation {
      
      // Updating this location
      
      savedLocation.update(name: name, location: location, color: color, distance: distance)
      MyDataManager.shared.saveMainContext()
      self.delegate?.didUpdate(savedLocation: savedLocation)
      
    } else {
      
      // Creating a location
      let savedLocation = SavedLocation.create(name: name, location: location, color: color, distance: distance)
      MyDataManager.shared.saveMainContext()
      self.delegate?.didSave(savedLocation: savedLocation)
    }
  }
}

// MARK: - InlineColorChooserViewControllerDelegate

extension LocationDetailViewController : InlineColorChooserViewControllerDelegate {
  
  func didSelect(color: UIColor) {
    if color != self.locationColor {
      self.locationColor = color
    }
  }
}

// MARK: - UITextFieldDelegate

extension LocationDetailViewController : UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if let _ = textField.text {
      return true
    }
    return false
  }
}
