//
//  AddLocationMapViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/6/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit
import MapKit

class AddLocationMapViewController : BaseViewController, DismissInteractable {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> AddLocationMapViewController {
    return self.newViewController(fromStoryboardWithName: "AddLocation")
  }
  
  static func newViewController(delegate: MyPlacemarkSearchViewControllerDelegate?) -> AddLocationMapViewController {
    let viewController = self.newViewController()
    viewController.delegate = delegate
    return viewController
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
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var addLocationButton: UIButton!
  
  weak var delegate: MyPlacemarkSearchViewControllerDelegate? = nil
  
  var locationManager: LocationManager {
    return LocationManager.shared
  }
  
  var currentAnnotation: MKAnnotation? = nil
  
  var currentMapItem: MapItem? = nil {
    didSet {
      if self.isViewLoaded {
        if self.currentMapItem != nil {
          self.view.bringSubview(toFront: self.addLocationButton)
          self.addLocationButton.isHidden = false
          self.addLocationButton.isUserInteractionEnabled = true
        } else {
          self.view.sendSubview(toBack: self.addLocationButton)
          self.addLocationButton.isHidden = true
          self.addLocationButton.isUserInteractionEnabled = false
        }
      }
    }
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = "Map"
    
    // Configure map
    self.mapView.delegate = self
    self.setMapInitialLocation()
    self.configureMapGestures()
    
    // Style add placemark button
    self.addLocationButton.layer.cornerRadius = 5
    self.addLocationButton.layer.masksToBounds = true
    self.addLocationButton.clipsToBounds = true
  }
  
  // MARK: - MKMapView
  
  func setMapInitialLocation() {
    let regionRadius: CLLocationDistance = MapItem.defaultRegionRadius
    let currentLocation = self.locationManager.currentLocation
    let desiredCoordinate = currentLocation?.coordinate ?? CLLocationCoordinate2D.denver80202
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(desiredCoordinate, regionRadius, regionRadius)
    self.mapView.setRegion(coordinateRegion, animated: true)
    self.mapView.showsUserLocation = true
    
    // Set the current map item as the user's current position if available
    if let currentLocation = currentLocation {
      let placemark = MKPlacemark(coordinate: currentLocation.coordinate)
      let mapItem = MKMapItem(placemark: placemark)
      self.currentMapItem = MapItem(mkMapItem: mapItem, currentLocation: currentLocation)
    }
  }
  
  func configureMapGestures() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleMapTap(_:)))
    self.mapView.addGestureRecognizer(tapGesture)
  }
  
  // MARK: - Gestures
  
  @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
    
    guard gesture.state == .ended else {
      return
    }
    
    // Check if already displaying an annotation
    if let currentAnnotation = self.currentAnnotation {
      self.mapView.removeAnnotation(currentAnnotation)
    }
    
    // Add the new annotation
    let touchPoint = gesture.location(in: self.mapView)
    let touchMapCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
    let annotation = MKPointAnnotation()
    annotation.coordinate = touchMapCoordinate
    self.currentAnnotation = annotation
    self.mapView.addAnnotation(annotation)
    
    // Set the current map item
    let placemark = MKPlacemark(coordinate: touchMapCoordinate)
    let mapItem = MKMapItem(placemark: placemark)
    self.currentMapItem = MapItem(mkMapItem: mapItem, currentLocation: self.locationManager.currentLocation)
  }
  
  // MARK: - Actions
  
  @IBAction func addPlacemarkButtonSelected() {
    if let mapItem = self.currentMapItem {
      self.delegate?.shouldAdd(mapItem: mapItem)
    }
  }
}

// MARK: - MKMapViewDelegate

extension AddLocationMapViewController : MKMapViewDelegate {
  
  // If no annotation has been added yet assume the selected postion is
  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    
    guard self.currentMapItem == nil else {
      return
    }
    
    // Use the user's current location as the current map item
    let placemark = MKPlacemark(coordinate: userLocation.coordinate)
    let mapItem = MKMapItem(placemark: placemark)
    self.currentMapItem = MapItem(mkMapItem: mapItem, currentLocation: self.locationManager.currentLocation)
  }
}
