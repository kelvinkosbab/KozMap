//
//  AddLocationContainerViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/12/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationContainerViewController : BaseViewController, DesiredContentHeightDelegate, DismissInteractable, KeyboardFrameRespondable {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> AddLocationContainerViewController {
    return self.newViewController(fromStoryboardWithName: "AddLocation")
  }
  
  static func newViewController(locationDetailDelegate: AddLocationViewControllerDelegate?, searchDelegate: MyPlacemarkSearchViewControllerDelegate?) -> AddLocationContainerViewController {
    let viewController = self.newViewController()
    viewController.locationDetailDelegate = locationDetailDelegate
    viewController.searchDelegate = searchDelegate
    viewController.preferredContentSize.height = viewController.desiredContentHeight
    return viewController
  }
  
  // MARK: - DesiredContentHeightDelegate
  
  var desiredContentHeight: CGFloat {
    return 378
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
    for viewController in self.orderedViewControllers {
      if let dismissInteractable = viewController as? DismissInteractable {
        views += dismissInteractable.dismissInteractiveViews
      }
    }
    return views
  }
  
  // MARK: - Properties
  
  private(set) var pageViewController: UIPageViewController? = nil
  weak var locationDetailDelegate: AddLocationViewControllerDelegate? = nil
  weak var searchDelegate: MyPlacemarkSearchViewControllerDelegate? = nil
  
  private(set) lazy var orderedViewControllers: [UIViewController] = {
    
    // Current location
    let currentLocationViewController = AddLocationViewController.newViewController(delegate: self.locationDetailDelegate)
    currentLocationViewController.view.backgroundColor = .clear
    
    // Search
    let searchViewController = MyPlacemarkSearchViewController.newViewController(delegate: self.searchDelegate)
    searchViewController.view.backgroundColor = .clear
    
    // Map
    let mapViewController = AddLocationMapViewController.newViewController(delegate: self.searchDelegate)
    mapViewController.view.backgroundColor = .clear
    
    return [ currentLocationViewController, searchViewController, mapViewController ]
  }()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.largeTitleDisplayMode = UIDevice.current.isPhone ? .never : .always
    if UIDevice.current.isPhone {
      self.baseNavigationController?.navigationBarStyle = .transparentBlueTint
      self.view.backgroundColor = .clear
    } else {
      self.baseNavigationController?.navigationBarStyle = .standard
      self.view.backgroundColor = .white
    }
    
    if !UIDevice.current.isPhone {
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(self.closeButtonSelected))
    }
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.reloadContent()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    guard let identifier = segue.identifier else {
      return
    }
    
    switch identifier {
    case "EmbedPageController":
      if let pageViewController = segue.destination as? UIPageViewController {
        self.pageViewController = pageViewController
        pageViewController.dataSource = self
        pageViewController.delegate = self
        if let firstViewController = self.orderedViewControllers.first {
          pageViewController.setViewControllers([ firstViewController ], direction: .forward, animated: true, completion: nil)
        }
      }
    default: break
    }
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
  
  // MARK: - Content
  
  var currentSelectedIndex: Int {
    if let _ = self.pageViewController?.viewControllers?.first as? AddLocationViewController {
      return 0
    } else if let _ = self.pageViewController?.viewControllers?.first as? MyPlacemarkSearchViewController {
      return 1
    } else if let _ = self.pageViewController?.viewControllers?.first as? AddLocationMapViewController {
      return 2
    }
    return 0
  }
  
  func reloadContent() {
    switch self.currentSelectedIndex {
    case 0:
      let searchButton = UIBarButtonItem(image: #imageLiteral(resourceName: "assetSearch"), style: .plain, target: self, action: #selector(self.searchNavigationButtonSelected))
      let mapButton = UIBarButtonItem(image: #imageLiteral(resourceName: "assetMapPlacemark"), style: .plain, target: self, action: #selector(self.mapNavigationButtonSelected))
      self.navigationItem.rightBarButtonItems = [ mapButton, searchButton ]
      self.navigationItem.title = "Current"
    case 1:
      let hereButton = UIBarButtonItem(image: #imageLiteral(resourceName: "assetPlacemark"), style: .plain, target: self, action: #selector(self.hereNavigationButtonSelected))
      let mapButton = UIBarButtonItem(image: #imageLiteral(resourceName: "assetMapPlacemark"), style: .plain, target: self, action: #selector(self.mapNavigationButtonSelected))
      self.navigationItem.rightBarButtonItems = [ mapButton, hereButton ]
      self.navigationItem.title = "Search"
    case 2:
      let hereButton = UIBarButtonItem(image: #imageLiteral(resourceName: "assetPlacemark"), style: .plain, target: self, action: #selector(self.hereNavigationButtonSelected))
      let searchButton = UIBarButtonItem(image: #imageLiteral(resourceName: "assetSearch"), style: .plain, target: self, action: #selector(self.searchNavigationButtonSelected))
      self.navigationItem.rightBarButtonItems = [ searchButton, hereButton ]
      self.navigationItem.title = "Map"
    default:
      self.navigationItem.rightBarButtonItems = nil
    }
    
    // Configure search controller
    self.navigationItem.searchController = self.pageViewController?.viewControllers?.first?.navigationItem.searchController
    self.navigationItem.hidesSearchBarWhenScrolling = self.pageViewController?.viewControllers?.first?.navigationItem.hidesSearchBarWhenScrolling ?? true
  }
  
  // MARK: - Actions
  
  @objc func closeButtonSelected() {
    self.dismissController()
  }
  
  @objc func hereNavigationButtonSelected() {
    let viewController = self.orderedViewControllers[0]
    self.pageViewController?.setViewControllers([ viewController ], direction: .reverse, animated: true, completion: nil)
    self.reloadContent()
  }
  
  @objc func searchNavigationButtonSelected() {
    let viewController = self.orderedViewControllers[1]
    let direction: UIPageViewControllerNavigationDirection = self.currentSelectedIndex < 1 ? .forward : .reverse
    self.pageViewController?.setViewControllers([ viewController ], direction: direction, animated: true, completion: nil)
    self.reloadContent()
  }
  
  @objc func mapNavigationButtonSelected() {
    let viewController = self.orderedViewControllers[2]
    self.pageViewController?.setViewControllers([ viewController ], direction: .forward, animated: true, completion: nil)
    self.reloadContent()
  }
}

// MARK: - UIPageViewControllerDataSource

extension AddLocationContainerViewController : UIPageViewControllerDataSource {
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    
    guard let viewControllerIndex = self.orderedViewControllers.index(of: viewController) else {
      return nil
    }
    
    let previousIndex = viewControllerIndex - 1
    
    guard previousIndex >= 0 else {
      return nil
    }
    
    guard self.orderedViewControllers.count > previousIndex else {
      return nil
    }
    
    return self.orderedViewControllers[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    
    guard let viewControllerIndex = self.orderedViewControllers.index(of: viewController) else {
      return nil
    }
    
    let nextIndex = viewControllerIndex + 1
    let orderedViewControllersCount = self.orderedViewControllers.count
    
    guard orderedViewControllersCount != nextIndex else {
      return nil
    }
    
    guard orderedViewControllersCount > nextIndex else {
      return nil
    }
    
    return self.orderedViewControllers[nextIndex]
  }
}

// MARK: - UIPageViewControllerDelegate

extension AddLocationContainerViewController : UIPageViewControllerDelegate {
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    self.reloadContent()
  }
}
