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
  
  static func newViewController(delegate: SearchViewControllerDelegate?) -> AddLocationMapViewController {
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
  
  weak var delegate: SearchViewControllerDelegate? = nil
  
  var locationManager: LocationManager {
    return LocationManager.shared
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Configure map
    self.mapView.delegate = self
    self.setMapInitialLocation()
  }
  
  // MARK: - MKMapView
  
  func setMapInitialLocation() {
    let regionRadius: CLLocationDistance = 800 // 800 meters ~ 0.5 miles
    let desiredCoordinate = self.locationManager.currentLocation?.coordinate ?? CLLocationCoordinate2D.denver80202
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(desiredCoordinate, regionRadius, regionRadius)
    self.mapView.setRegion(coordinateRegion, animated: true)
  }
}

// MARK: - MKMapViewDelegate

extension AddLocationMapViewController : MKMapViewDelegate {
  
}
