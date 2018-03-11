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

class SearchFoodNearbyViewController : BaseTableViewController, DismissInteractable {
  
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
    if let navigationBar = self.navigationController?.navigationBar {
      views.append(navigationBar)
    }
    if let tableView = self.tableView {
      views.append(tableView)
    }
    return views
  }
  
  // MARK: - Properties
  
  weak var delegate: SearchFoodNearbyViewControllerDelegate? = nil
  let locationSearchService = LocationSearchService()
  var resultSearchController: UISearchController? = nil
  var mapItems: [MapItem] = []
  
  var currentLocation: CLLocation? {
    return LocationManager.shared.currentLocation
  }
  
  var searchBar: UISearchBar? {
    return self.navigationItem.searchController?.searchBar
  }
  
  override var navigationController: UINavigationController? {
    return super.navigationController ?? self.parent?.navigationController
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = "Search"
    
    if !UIDevice.current.isPhone {
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(self.closeButtonSelected))
    }
    
    // Configure the search bar
    let searchController = UISearchController(searchResultsController: nil)
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchResultsUpdater = nil
    searchController.searchBar.placeholder = "Search for..."
    self.navigationItem.searchController = searchController
    searchController.searchBar.delegate = self
    
    // Configure navigation bar
    self.baseNavigationController?.navigationBarStyle = .transparentBlueTint
    self.navigationItem.largeTitleDisplayMode = .never
    self.navigationItem.hidesSearchBarWhenScrolling = false
    
    // Styles based on presentation mode
    switch self.presentedMode {
    case .custom(.topKnobBottomUp):
      self.navigationController?.view.backgroundColor = .clear
      self.view.backgroundColor = .clear
      self.tableView.backgroundColor = .clear
    default: break
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Listen for updates to current location
    NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveUpdatedLocationNotification(_:)), name: .locationManagerDidUpdateCurrentLocation, object: nil)
    
    // Pre-fetch last search
    self.performSearch(text: Defaults.shared.lastFoodSearchText)
    
    self.searchBar?.text = Defaults.shared.lastFoodSearchText == Defaults.shared.defaultFoodSearchText ? "" : Defaults.shared.lastFoodSearchText
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.searchBar?.resignFirstResponder()
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
  
  // MARK: - Actions
  
  @objc func closeButtonSelected() {
    self.dismissController()
  }
}

// MARK: - UITableView

extension SearchFoodNearbyViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.mapItems.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    guard let text = text, let currentLocation = self.currentLocation else {
      return
    }
    
    // Update the last search result
    Defaults.shared.lastFoodSearchText = text
    
    // Query for food nearby
    self.locationSearchService.queryLocations(query: text, currentLocation: currentLocation) { [weak self] mapItems in
      self?.reloadContent(mapItems: mapItems)
    }
  }
}
