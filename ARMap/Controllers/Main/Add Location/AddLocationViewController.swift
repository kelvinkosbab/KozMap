//
//  AddLocationViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit
import CoreLocation

protocol AddLocationViewControllerDelegate : class {
  func didSave(placemark: Placemark)
}

class AddLocationViewController : BaseViewController, DesiredContentHeightDelegate, DismissInteractable {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> AddLocationViewController {
    let viewController = self.newViewController(fromStoryboardWithName: "AddLocation")
    viewController.preferredContentSize.height = viewController.desiredContentHeight
    return viewController
  }
  
  static func newViewController(delegate: AddLocationViewControllerDelegate?) -> AddLocationViewController {
    let viewController = self.newViewController()
    viewController.delegate = delegate
    return viewController
  }
  
  static func newViewController(mapItem: MapItem, delegate: AddLocationViewControllerDelegate?) -> AddLocationViewController {
    let viewController = self.newViewController()
    viewController.mapItem = mapItem
    viewController.location = mapItem.placemark.location
    viewController.delegate = delegate
    return viewController
  }
  
  // MARK: - DesiredContentHeightDelegate
  
  var desiredContentHeight: CGFloat {
    return 338
  }
  
  // MARK: - DismissInteractable
  
  var dismissInteractiveViews: [UIView] {
    var views: [UIView] = []
    if let view = self.view {
      views.append(view)
    }
    return views
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var locationDescriptionLabel: UILabel!
  @IBOutlet weak var addLocationButton: UIButton!
  @IBOutlet weak var colorChooserContainer: UIView!
  
  weak var delegate: AddLocationViewControllerDelegate? = nil
  var colorChooserController: InlineColorChooserViewController? = nil
  
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
    case creating, creatingMapItem
  }
  
  var state: LocationDetailState {
    return self.mapItem == nil ? .creating : .creatingMapItem
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.nameTextField.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
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
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.nameTextField.resignFirstResponder()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    // Configure the color chooser
    if self.colorChooserController == nil {
      self.configureColorChooser()
    }
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
    }
  }
  
  // MARK: - Content
  
  func reloadContent() {
    
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
      self.distanceLabel.text = "NA"
      self.locationDescriptionLabel.text = ""
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
    
    // Update the distance
    let currentLocation = LocationManager.shared.currentLocation
    let distance = currentLocation?.distance(from: location)
    self.distanceLabel.text = distance?.getDistanceString(unitType: Defaults.shared.unitType, displayType: .numbericUnits(false)) ?? "NA"
    
    // Location address
    location.getPlacemark { [weak self] placemark in
      self?.locationDescriptionLabel.text = placemark?.address
    }
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
    let color = Color.create()
    color.color = self.locationColor
    
    // Address
    let address = self.mapItem?.address
    
    // Distance
    let currentLocation = LocationManager.shared.currentLocation
    let distance = currentLocation?.distance(from: location)
    
    // Create the location
    let placemark = Placemark.create(name: name, location: location, color: color, distance: distance)
    placemark.address = address
    MyDataManager.shared.saveMainContext()
    self.delegate?.didSave(placemark: placemark)
  }
}

// MARK: - InlineColorChooserViewControllerDelegate

extension AddLocationViewController : InlineColorChooserViewControllerDelegate {
  
  func didSelect(color: UIColor) {
    if color != self.locationColor {
      self.locationColor = color
    }
  }
}

// MARK: - UITextFieldDelegate

extension AddLocationViewController : UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    if let _ = textField.text {
      return true
    }
    return false
  }
}
