//
//  SearchFoodNearbyViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/9/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class SearchFoodNearbyViewController : BaseTableViewController, DismissInteractable {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> SearchFoodNearbyViewController {
    return self.newViewController(fromStoryboardWithName: "FoodNearby")
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
  
  var resultSearchController: UISearchController? = nil
  var mapItems: [MapItem] = []
  
  var foodNearbyService: FoodNearbyService {
    return FoodNearbyService.shared
  }
  
  var searchBar: UISearchBar? {
    return self.navigationItem.searchController?.searchBar
  }
  
  override var navigationController: UINavigationController? {
    return super.navigationController ?? self.parent?.navigationController
  }
  
  var foodPlacemarks: [FoodPlacemark] {
    return self.foodPlacemarksFetchedResultsController.fetchedObjects ?? []
  }
  
  private lazy var foodPlacemarksFetchedResultsController: NSFetchedResultsController<FoodPlacemark> = {
    let controller = FoodPlacemark.newFetchedResultsController()
    controller.delegate = self
    try? controller.performFetch()
    return controller
  }()
  
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
    
    // Configure the search bar
    self.searchBar?.text = self.foodNearbyService.displaySearchText
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
  
  func reloadContent() {
    self.tableView.reloadData()
  }
  
  // MARK: - SectionType
  
  enum SectionType {
    case foodPlacemarks([FoodPlacemark])
  }
  
  func getSectionType(section: Int) -> SectionType? {
    switch section {
    case 0:
      let foodPlacemarks = self.foodPlacemarks
      return .foodPlacemarks(foodPlacemarks)
    default:
      return nil
    }
  }
  
  // MARK: - RowType
  
  enum RowType {
    case foodPlacemark(FoodPlacemark)
  }
  
  func getRowType(at indexPath: IndexPath) -> RowType? {
    
    guard let sectionType = self.getSectionType(section: indexPath.section) else {
      return nil
    }
    
    switch sectionType {
    case .foodPlacemarks(let foodPlacemarks):
      if indexPath.row < foodPlacemarks.count {
        let foodPlacemark = foodPlacemarks[indexPath.row]
        return .foodPlacemark(foodPlacemark)
      }
      return nil
    }
  }
  
  // MARK: - UITableView
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    guard let sectionType = self.getSectionType(section: section) else {
      return 0
    }
    
    switch sectionType {
    case .foodPlacemarks(let foodPlacemarks):
      return foodPlacemarks.count
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SearchViewControllerCell.name, for: indexPath) as! SearchViewControllerCell
    cell.backgroundColor = .clear
    
    guard let rowType = self.getRowType(at: indexPath) else {
      cell.titleLabel.text = ""
      cell.detailLabel.text = ""
      cell.rightDetailLabel.text = ""
      return cell
    }
    
    switch rowType {
    case .foodPlacemark(let foodPlacemark):
      
      cell.titleLabel.text = foodPlacemark.name
      cell.detailLabel.text = foodPlacemark.address
      
      // Distance label
      let readibleDistance = foodPlacemark.lastDistance.getDistanceString(unitType: Defaults.shared.unitType, displayType: .numbericUnits(false))
      cell.rightDetailLabel.text = readibleDistance
      
      return cell
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard let rowType = self.getRowType(at: indexPath) else {
      return
    }
    
    // TODO: Favorite this item?
  }
}

// MARK: - NSFetchedResultsControllerDelegate

extension SearchFoodNearbyViewController : NSFetchedResultsControllerDelegate {
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    self.reloadContent()
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
  
  private func performSearch(text: String?) {
    
    // Update the last search result
    self.foodNearbyService.currentSearchText = text
  }
}
