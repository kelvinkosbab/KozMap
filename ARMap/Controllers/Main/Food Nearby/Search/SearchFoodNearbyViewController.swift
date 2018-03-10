//
//  SearchFoodNearbyViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/9/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit
import CoreLocation

protocol SearchFoodNearbyViewControllerDelegate : class {
  func shouldAdd(foodNearybyMapItem mapItem: MapItem)
}

class SearchFoodNearbyViewController : BaseViewController, DismissInteractable {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> SearchFoodNearbyViewController {
    return self.newViewController(fromStoryboardWithName: "FoodNearby")
  }
  
  static func newViewController(delegate: SearchFoodNearbyViewControllerDelegate?) -> SearchFoodNearbyViewController {
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
    if let tableView = self.tableView {
      views.append(tableView)
    }
    return views
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  weak var delegate: SearchFoodNearbyViewControllerDelegate? = nil
  let locationSearchService = LocationSearchService()
  var resultSearchController: UISearchController? = nil
  var mapItems: [MapItem] = []
  
  var currentLocation: CLLocation? {
    return LocationManager.shared.currentLocation
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.searchBar.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Listen for current location updates
    NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveUpdatedLocationNotification(_:)), name: .locationManagerDidUpdateCurrentLocation, object: nil)
    
    // Pre-fill data
    self.performSearch(text: "food")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.searchBar.resignFirstResponder()
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
    self.reloadContent(mapItems: self.mapItems)
  }
  
  // MARK: - Content
  
  func reloadContent(mapItems: [MapItem]) {
    self.mapItems = mapItems
    self.tableView.reloadData()
  }
}

// MARK: - UITableView

extension SearchFoodNearbyViewController : UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.mapItems.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SearchViewControllerCell", for: indexPath) as! SearchViewControllerCell
    cell.backgroundColor = .clear
    
    let mapItem = self.mapItems[indexPath.row]
    cell.titleLabel.text = mapItem.name
    cell.detailLabel.text = mapItem.address
    
    // Distance label
    let readibleDistance = mapItem.distance?.getDistanceString(unitType: Defaults.shared.unitType, displayType: .numbericUnits(false))
    cell.rightDetailLabel.text = readibleDistance
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    // Add the map item
    let mapItem = self.mapItems[indexPath.row]
    self.delegate?.shouldAdd(foodNearybyMapItem: mapItem)
  }
}

// MARK: - UISearchBarDelegate

extension SearchFoodNearbyViewController : UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    self.performSearch(text: searchBar.text)
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    self.performSearch(text: searchText)
  }
  
  func performSearch(text: String?) {
    
    guard let text = self.searchBar.text, let currentLocation = self.currentLocation else {
      return
    }
    
    self.locationSearchService.queryLocations(query: text, currentLocation: currentLocation) { [weak self] mapItems in
      self?.reloadContent(mapItems: mapItems)
    }
  }
}
