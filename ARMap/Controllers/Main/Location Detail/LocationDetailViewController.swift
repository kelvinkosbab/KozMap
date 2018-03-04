//
//  LocationDetailViewController.swift
// KozMap
//
//  Created by Kelvin Kosbab on 1/20/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import UIKit
import CoreData

class LocationDetailViewController : BaseViewController, NSFetchedResultsControllerDelegate, DesiredContentHeightDelegate, DismissInteractable, KeyboardFrameRespondable, PlacemarkAPIDelegate {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> LocationDetailViewController {
    let viewController = self.newViewController(fromStoryboardWithName: "AddLocation")
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
    return 271
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
  @IBOutlet weak var colorChooserContainer: UIView!
  
  var placemark: Placemark? = nil
  var colorChooserController: InlineColorChooserViewController? = nil
  
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
    
    // Location address
    let address = placemark.address
    self.locationDescriptionLabel.text = address
    location.getPlacemark { [weak self] placemark in
      self?.locationDescriptionLabel.text = address ?? placemark?.address
    }
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
