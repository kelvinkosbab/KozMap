//
//  AddLocationViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/12/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit

class AddLocationViewController : BaseViewController {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> AddLocationViewController {
    return self.newViewController(fromStoryboardWithName: "Main")
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var currentLocationButton: UIButton!
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var pagingContainerView: UIView!
  
  // MARK: - Actions
  
  @IBAction func currentLocationButtonSelected() {
    
  }
  
  @IBAction func searchButtonSelected() {
    
  }
}
