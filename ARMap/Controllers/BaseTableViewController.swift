//
//  BaseTableViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

class BaseTableViewController : UITableViewController, PresentableController {
  
  // MARK: - PresentableController
  
  var presentedMode: PresentationMode = .modal(.formSheet, .coverVertical)
  var presentationManager: UIViewControllerTransitioningDelegate? = nil
  var currentFlowInitialController: PresentableController? = nil
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.configureDefaultBackButton()
  }
  
  // MARK: - Status Bar
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - UITableView
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
}

extension BaseTableViewController {
  
  var baseNavigationController: BaseNavigationController? {
    return self.navigationController as? BaseNavigationController
  }
}
