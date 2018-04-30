//
//  MainViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit
import CoreData

class MainViewController : BaseViewController {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> MainViewController {
    return self.newViewController(fromStoryboardWithName: "Main")
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var tabBarVisualEffectView: UIVisualEffectView!
  @IBOutlet weak var homeTabBarContainerView: UIView!
  weak var homeTabBarView: HomeTabBarView?
  
  internal var arViewController: ARViewController? = nil
  internal var appMode: AppMode = .myPlacemark
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Navigation bar
    self.navigationItem.title = nil
    self.navigationController?.isNavigationBarHidden = false
    self.navigationItem.largeTitleDisplayMode = .never
    
    // Configure views
    self.configureView()
  }
  
  // MARK: - Views
  
  func configureView() {
    
    // Configure the home tab bar view
    let homeTabBarView = HomeTabBarView.newView(appMode: self.appMode, delegate: self)
    homeTabBarView.backgroundColor = .clear
    self.homeTabBarView = homeTabBarView
    homeTabBarView.addToContainer(self.homeTabBarContainerView)
    
    // For simulators add an image view to give simulated location context
    if UIDevice.current.isSimulator {
      let imageView = UIImageView(image: #imageLiteral(resourceName: "denverCityScape"))
      imageView.contentMode = .scaleAspectFill
      imageView.addToContainer(self.view, atIndex: 1)
    }
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let arViewController = segue.destination as? ARViewController {
      arViewController.delegate = self
      arViewController.trackingStateDelegate = self
      self.arViewController = arViewController
    }
  }
  
  // MARK: - Showing and Enabling Views
  
  func showAllElements() {
    self.tabBarVisualEffectView.effect = UIBlurEffect(style: .light)
    self.homeTabBarContainerView.alpha = 1
  }
  
  func enableAllElements() {
    self.homeTabBarContainerView.isUserInteractionEnabled = true
  }
  
  func disableAllElements() {
    self.homeTabBarContainerView.isUserInteractionEnabled = false
  }
  
  func hideAllElements() {
    self.tabBarVisualEffectView.effect = nil
    self.homeTabBarContainerView.alpha = 0
  }
}
