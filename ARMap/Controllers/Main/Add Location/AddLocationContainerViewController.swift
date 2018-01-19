//
//  AddLocationContainerViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/12/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationContainerViewController : BaseViewController, DesiredContentHeightDelegate, KeyboardFrameRespondable {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> AddLocationContainerViewController {
    return self.newViewController(fromStoryboardWithName: "AddLocation")
  }
  
  static func newViewController(locationDetailDelegate: AddLocationViewControllerDelegate?, searchDelegate: SearchViewControllerDelegate?) -> AddLocationContainerViewController {
    let viewController = self.newViewController()
    viewController.locationDetailDelegate = locationDetailDelegate
    viewController.searchDelegate = searchDelegate
    return viewController
  }
  
  // MARK: - DesiredContentHeightDelegate
  
  var desiredContentHeight: CGFloat {
    return 335
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var pagingContainerView: UIView!
  
  var pageViewController: UIPageViewController? = nil
  weak var locationDetailDelegate: AddLocationViewControllerDelegate? = nil
  weak var searchDelegate: SearchViewControllerDelegate? = nil
  
  private(set) lazy var orderedViewControllers: [UIViewController] = {
    let currentLocationViewController = AddLocationViewController.newViewController(delegate: self.locationDetailDelegate)
    let searchViewController = SearchViewController.newViewController(delegate: self.searchDelegate)
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
  }
  
  // MARK: - Content
  
  var currentSelectedIndex: Int {
    if let _ = self.pageViewController?.viewControllers?.first as? AddLocationViewController {
      return 0
    } else {
      return 1
    }
  }
  
  func reloadContent() {
    self.segmentedControl.selectedSegmentIndex = self.currentSelectedIndex
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
