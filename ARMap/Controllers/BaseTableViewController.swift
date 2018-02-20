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
  
  var presentedMode: PresentationMode = .modal
  var presentationManager: UIViewControllerTransitioningDelegate? = nil
  var currentFlowInitialController: PresentableController? = nil
  
  // MARK: - UITableView
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
}
