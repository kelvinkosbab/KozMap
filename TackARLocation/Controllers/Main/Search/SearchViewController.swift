//
//  SearchViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/12/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController : BaseViewController {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> SearchViewController {
    return self.newViewController(fromStoryboardWithName: "AddLocation")
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  let locationSearchService = LocationSearchService()
  var resultSearchController: UISearchController? = nil
  
  var currentLocation: CLLocation? {
    return LocationManager.shared.currentLocation
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
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
    self.reloadContent()
  }
  
  // MARK: - Content
  
  func reloadContent() {
    
  }
}

// MARK: - UITableView

extension SearchViewController : UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
}

// MARK: - UISearchResultsUpdating

extension SearchViewController : UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    
    guard let text = searchController.searchBar.text, let currentLocation = self.currentLocation else {
      return
      
    }
    
    self.locationSearchService.queryLocations(query: text, currentLocation: currentLocation) { mapItems in
      print("KAK found \(mapItems.count) map items")
    }
  }
}
