//
//  AddLocationViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/12/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationViewController : BaseViewController {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> AddLocationViewController {
    return self.newViewController(fromStoryboardWithName: "AddLocation")
  }
  
  static func newViewController(location: CLLocation?, delegate: LocationDetailViewControllerDelegate?) -> AddLocationViewController {
    let viewController = self.newViewController()
    viewController.location = location
    viewController.delegate = delegate
    return viewController
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var pagingContainerView: UIView!
  @IBOutlet weak var pageControl: UIPageControl!
  
  let preferredContentHeight: CGFloat = 325
  var pageViewController: UIPageViewController? = nil
  weak var delegate: LocationDetailViewControllerDelegate? = nil
  var location: CLLocation? = nil {
    didSet {
//      if self.isViewLoaded && self.isCreatingSavedLocation {
//        self.reloadContent()
//      }
    }
  }
  
  private(set) lazy var orderedViewControllers: [UIViewController] = {
    let currentLocationViewController = LocationDetailViewController.newViewController(location: self.location, delegate: self.delegate)
    let searchViewController = SearchViewController.newViewController()
    return [ currentLocationViewController, searchViewController ]
  }()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Configure the page view controller
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    self.add(childViewController: pageViewController, intoContainerView: self.pagingContainerView)
    self.pageViewController = pageViewController
    pageViewController.dataSource = self
    pageViewController.delegate = self
    if let firstViewController = self.orderedViewControllers.first {
      pageViewController.setViewControllers([ firstViewController ], direction: .forward, animated: true, completion: nil)
    }
    
    // Page control
    self.pageControl.numberOfPages = 2
    self.pageControl.currentPage = 0
  }
  
  // MARK: - Content
  
  var currentSelectedIndex: Int {
    if let _ = self.pageViewController?.viewControllers?.first as? LocationDetailViewController {
      return 0
    } else {
      return 1
    }
  }
  
  func reloadContent() {
    self.segmentedControl.selectedSegmentIndex = self.currentSelectedIndex
    self.pageControl.currentPage = self.currentSelectedIndex
  }
  
  // MARK: - Actions
  
  @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      if self.currentSelectedIndex != 0 {
        let viewController = self.orderedViewControllers[0]
        self.pageViewController?.setViewControllers([ viewController ], direction: .reverse, animated: true, completion: nil)
      }
    default:
      if self.currentSelectedIndex != 1 {
        let viewController = self.orderedViewControllers[1]
        self.pageViewController?.setViewControllers([ viewController ], direction: .forward, animated: true, completion: nil)
      }
    }
  }
}

// MARK: - UIPageViewControllerDataSource

extension AddLocationViewController : UIPageViewControllerDataSource {
  
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

extension AddLocationViewController : UIPageViewControllerDelegate {
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    self.reloadContent()
  }
}
