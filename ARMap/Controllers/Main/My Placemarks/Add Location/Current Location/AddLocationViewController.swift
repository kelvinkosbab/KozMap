//
//  AddLocationViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

protocol AddLocationViewControllerDelegate : class {
  func didSave(placemark: Placemark)
}

class AddLocationViewController : BaseViewController, DesiredContentHeightDelegate, DismissInteractable {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> AddLocationViewController {
    return self.newViewController(fromStoryboardWithName: "AddLocation")
  }
  
  static func newViewController(delegate: AddLocationViewControllerDelegate?) -> AddLocationViewController {
    let viewController = self.newViewController()
    viewController.delegate = delegate
    viewController.preferredContentSize.height = viewController.desiredContentHeight
    return viewController
  }
  
  static func newViewController(mapItem: MapItem, delegate: AddLocationViewControllerDelegate?) -> AddLocationViewController {
    let viewController = self.newViewController()
    viewController.mapItem = mapItem
    viewController.location = mapItem.placemark.location
    viewController.delegate = delegate
    viewController.preferredContentSize.height = viewController.desiredContentHeight
    return viewController
  }
  
  // MARK: - DesiredContentHeightDelegate
  
  var desiredContentHeight: CGFloat {
    return UIScreen.main.bounds.height
  }
  
  // MARK: - DismissInteractable
  
  var dismissInteractiveViews: [UIView] {
    var views: [UIView] = []
    if let view = self.view {
      views.append(view)
    }
    if let mapView = self.mapView {
      views.append(mapView)
    }
    return views
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var locationDescriptionLabel: UILabel!
  @IBOutlet weak var locationDescriptionLabelHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var addLocationButton: UIButton!
  @IBOutlet weak var colorChooserContainer: UIView!
  @IBOutlet weak var mapView: MKMapView!
  
  weak var delegate: AddLocationViewControllerDelegate? = nil
  var colorChooserController: InlineColorChooserViewController? = nil
  
  var mapItem: MapItem? = nil
  var locationColor: UIColor = .kozRed
  var mapAnnotation: MKAnnotation? = nil
  
  var clPlacemark: CLPlacemark? = nil {
    didSet {
      if self.isViewLoaded {
        self.reloadContent()
      }
    }
  }
  
  var location: CLLocation? = nil {
    didSet {
      if self.isViewLoaded && self.state == .creating {
        self.reloadContent()
        
        // Update the placemark
        self.location?.getPlacemark { [weak self] placemark in
          self?.clPlacemark = placemark
        }
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
    
    // Navigation bar styles
    self.navigationItem.largeTitleDisplayMode = UIDevice.current.isPhone ? .never : .always
    if UIDevice.current.isPhone {
      self.baseNavigationController?.navigationBarStyle = .transparentBlueTint
      self.view.backgroundColor = .clear
    } else {
      self.baseNavigationController?.navigationBarStyle = .standard
      self.view.backgroundColor = .white
    }
    
    // Title
    if let _ = self.mapItem {
      self.navigationItem.title = "Add Placemark"
    } else {
      self.navigationItem.title = "Current"
    }
    
    // Navigation buttons
    if UIDevice.current.isPhone {
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icChevronDown"), style: .plain, target: self, action: #selector(self.closeButtonSelected))
    } else {
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(self.closeButtonSelected))
    }
    
    // UITextFieldDelegate
    self.nameTextField.delegate = self
    
    // Set the initial name for the placemark
    self.nameTextField.text = (self.nameTextField.text?.isEmpty ?? true) && self.mapItem?.name == "Unknown Location" ? nil : self.mapItem?.name
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
    
    // Placemark address
    self.location?.getPlacemark { [weak self] placemark in
      self?.clPlacemark = placemark
    }
    
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
    
    // Placemark description
    self.locationDescriptionLabel.text = self.placemarkDescription
    self.locationDescriptionLabelHeightConstraint.constant = self.placemarkDescription?.calculateHeight(forLabel: self.locationDescriptionLabel) ?? 0
    
    // Check if view not tall enough for mapView
    guard self.view.bounds.height > 600 else {
      self.mapView.isHidden = true
      return
    }
    
    // Insure map view is displayed
    if self.mapView.isHidden {
      self.mapView.isHidden = false
    }
    
    // Map annotion
    if let mapAnnotation = self.mapAnnotation, mapAnnotation.coordinate.latitude == coordinate.latitude && mapAnnotation.coordinate.longitude == coordinate.longitude {
      // do nothing
    } else {
      
      // Need to create/update the current annotation
      if let mapAnnotation = self.mapAnnotation {
        self.mapView.removeAnnotation(mapAnnotation)
      }
      
      // Create the map annotation
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      self.mapAnnotation = annotation
      self.mapView.addAnnotation(annotation)
      self.mapView.showsUserLocation = true
      self.mapView.isScrollEnabled = false
      self.mapView.isUserInteractionEnabled = false
      
      // Set the map region
      let regionRadius: CLLocationDistance = MapItem.defaultRegionRadius
      let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius, regionRadius)
      self.mapView.setRegion(coordinateRegion, animated: true)
    }
  }
  
  var placemarkDescription: String? {
    var placemarkDescription: String = ""
    let address = self.mapItem?.address ?? self.clPlacemark?.address
    if let address = address {
      placemarkDescription += address
    }
    if let phoneNumber = self.mapItem?.phoneNumber {
      if address != nil {
        placemarkDescription += "\n"
      }
      placemarkDescription += phoneNumber
    }
    return placemarkDescription.count > 0 ? placemarkDescription : nil
  }
  
  // MARK: - Actions
  
  @objc func closeButtonSelected() {
    self.dismissController()
  }
  
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
    let address = self.mapItem?.address ?? self.clPlacemark?.address
    
    // Distance
    let currentLocation = LocationManager.shared.currentLocation
    let distance = currentLocation?.distance(from: location)
    
    // Create the location
    let placemark = Placemark.create(placemarkType: .myPlacemark, name: name, location: location, color: color, distance: distance, address: address)
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
