//
//  LocationDetailViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 1/20/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class LocationDetailViewController : BaseViewController, NSFetchedResultsControllerDelegate, DesiredContentHeightDelegate, DismissInteractable, KeyboardFrameRespondable, PlacemarkAPIDelegate {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> LocationDetailViewController {
    let viewController = self.newViewController(fromStoryboardWithName: "LocationDetail")
    viewController.preferredContentSize.height = viewController.desiredContentHeight
    return viewController
  }
  
  static func newViewController(placemark: Placemark) -> LocationDetailViewController {
    let viewController = self.newViewController()
    viewController.placemark = placemark
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
  @IBOutlet weak var colorChooserContainer: UIView!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var openInMapsButton: UIButton!
  
  var placemark: Placemark? = nil
  var colorChooserController: InlineColorChooserViewController? = nil
  var mapAnnotation: MKAnnotation? = nil
  
  var mapItem: MapItem? {
    
    guard let placemark = self.placemark else {
      return nil
    }
    
    let mkPlacemark = MKPlacemark(coordinate: placemark.location.coordinate)
    let mkMapItem = MKMapItem(placemark: mkPlacemark)
    return MapItem(mkMapItem: mkMapItem, currentLocation: LocationManager.shared.currentLocation)
  }
  
  private lazy var placemarksFetchedResultsController: NSFetchedResultsController<Placemark>? = {
    
    guard let placemark = self.placemark else {
      return nil
    }
    
    let controller = Placemark.newFetchedResultsController(placemark: placemark)
    controller.delegate = self
    try? controller.performFetch()
    return controller
  }()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = self.placemark?.name
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteButtonSelected))
    
    // Style open in maps button
    self.openInMapsButton.layer.cornerRadius = 5
    self.openInMapsButton.layer.masksToBounds = true
    self.openInMapsButton.clipsToBounds = true
  }
  
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
    self.fetchUpdatedAddress()
    
    // Listen for updates to current location
    NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveUpdatedLocationNotification(_:)), name: .locationManagerDidUpdateCurrentLocation, object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.nameTextField.resignFirstResponder()
    MyDataManager.shared.saveMainContext()
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
    self.reloadContent()
  }
  
  // MARK: - NSFetchedResultsControllerDelegate
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    if controller == self.placemarksFetchedResultsController {
      
      guard let placemark = self.placemarksFetchedResultsController?.fetchedObjects?.first else {
        return
      }
      
      self.placemark = placemark
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
  
  func fetchUpdatedAddress() {
    self.placemark?.location.getPlacemark { [weak self] clPlacemark in
      if let address = clPlacemark?.address, self?.placemark?.address != address {
        self?.placemark?.address = address
        MyDataManager.shared.saveMainContext()
        self?.reloadContent()
      }
    }
  }
  
  func reloadContent() {
    
    // Check if there is a location to populate
    guard let placemark = self.placemark else {
      self.title = nil
      self.latitudeLabel.text = "NA"
      self.longitudeLabel.text = "NA"
      self.distanceLabel.text = "NA"
      self.locationDescriptionLabel.text = ""
      return
    }
    
    // Name
    self.title = placemark.name
    self.nameTextField.text = placemark.name
    self.nameTextField.isUserInteractionEnabled = placemark.placemarkType == .myPlacemark
    
    // Color
    if let color = placemark.color?.color {
      self.colorChooserController?.selectedColor = color
    }
    
    // Update the current location
    let location = placemark.location
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
    
    // Map annotion
    if let mapAnnotation = self.mapAnnotation, mapAnnotation.coordinate.latitude == placemark.coordinate.latitude && mapAnnotation.coordinate.longitude == placemark.coordinate.longitude {
      // do nothing
    } else {
      
      // Need to create/update the current annotation
      if let mapAnnotation = self.mapAnnotation {
        self.mapView.removeAnnotation(mapAnnotation)
      }
      
      // Create the map annotation
      let annotation = MKPointAnnotation()
      annotation.coordinate = placemark.coordinate
      self.mapAnnotation = annotation
      self.mapView.addAnnotation(annotation)
      self.mapView.showsUserLocation = true
      self.mapView.isScrollEnabled = false
      self.mapView.isUserInteractionEnabled = false
      
      // Set the map region
      let regionRadius: CLLocationDistance = MapItem.defaultRegionRadius
      let coordinateRegion = MKCoordinateRegionMakeWithDistance(placemark.coordinate, regionRadius, regionRadius)
      self.mapView.setRegion(coordinateRegion, animated: true)
    }
  }
  
  var placemarkDescription: String? {
    
    guard let placemark = self.placemark, placemark.address != nil || placemark.phoneNumber != nil else {
      return nil
    }
    
    var placemarkDescription: String = ""
    if let address = placemark.address {
      placemarkDescription += address
    }
    if let phoneNumber = placemark.phoneNumber {
      if placemark.address != nil {
        placemarkDescription += "\n"
      }
      placemarkDescription += phoneNumber
    }
    return placemarkDescription
  }
  
  // MARK: - Actions
  
  @IBAction func nameTextFieldEditingChanged(_ sender: UITextField) {
    self.placemark?.name = sender.text
  }
  
  @objc func deleteButtonSelected() {
    
    // Delete the placemark
    if let placemark = self.placemark {
      self.promptDeletePlacemark(placemark: placemark) { [weak self] in
        
        // Dismiss
        self?.dismissController()
      }
    }
  }
  
  @IBAction func openInMapsButtonSelected() {
    
    // Open in maps
    self.mapItem?.openInMaps(customName: self.placemark?.name)
  }
}

// MARK: - InlineColorChooserViewControllerDelegate

extension LocationDetailViewController : InlineColorChooserViewControllerDelegate {
  
  func didSelect(color: UIColor) {
    self.placemark?.color?.color = color
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
