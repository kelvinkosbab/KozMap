//
//  SearchViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/12/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit
import CoreLocation

protocol SearchViewControllerDelegate : class {
  func shouldAdd(mapItem: MapItem)
}

class SearchViewController : BaseViewController {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> SearchViewController {
    return self.newViewController(fromStoryboardWithName: "AddLocation")
  }
  
  static func newViewController(delegate: SearchViewControllerDelegate?) -> SearchViewController {
    let viewController = self.newViewController()
    viewController.delegate = delegate
    return viewController
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  weak var delegate: SearchViewControllerDelegate? = nil
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
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveUpdatedLocationNotification(_:)), name: .locationManagerDidUpdateCurrentLocation, object: nil)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    NotificationCenter.default.removeObserver(self)
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

extension SearchViewController : UITableViewDelegate, UITableViewDataSource {
  
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
    let distance = mapItem.distance
    let readibleDistance = distance?.getBasicReadibleDistance(nearUnitType: Defaults.shared.nearUnitType, farUnitType: Defaults.shared.farUnitType)
    cell.rightDetailLabel.text = readibleDistance
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    // Add the map item
    let mapItem = self.mapItems[indexPath.row]
    self.delegate?.shouldAdd(mapItem: mapItem)
  }
}

// MARK: - UISearchBarDelegate

extension SearchViewController : UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    self.performSearch(text: searchBar.text)
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    self.performSearch(text: searchText)
  }
  
  private func performSearch(text: String?) {
    
    guard let text = searchBar.text, let currentLocation = self.currentLocation else {
      return
    }
    
    self.locationSearchService.queryLocations(query: text, currentLocation: currentLocation) { [weak self] mapItems in
      self?.reloadContent(mapItems: mapItems)
    }
  }
}
