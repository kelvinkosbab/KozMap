//
//  HomeTabBarView.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/7/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

enum HomeTabBarButtonType {
  case settings, list, add, mode
}

protocol HomeTabBarViewDelegate : class {
  func tabButtonSelected(type: HomeTabBarButtonType, mode: AppMode)
}

class HomeTabBarView : UIView {
  
  // MARK: - Static Accessors
  
  private static func newView() -> HomeTabBarView {
    return UINib(nibName: "HomeTabBarView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! HomeTabBarView
  }
  
  static func newView(mode: AppMode, delegate: HomeTabBarViewDelegate?) -> HomeTabBarView {
    let view = self.newView()
    view.mode = mode
    view.delegate = delegate
    return view
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var settingsButton: UIButton!
  @IBOutlet weak var addButton: UIButton!
  @IBOutlet weak var listButton: UIButton!
  @IBOutlet weak var centerListButton: UIButton!
  @IBOutlet weak var modeButton: UIButton!
  
  weak var delegate: HomeTabBarViewDelegate? = nil
  
  var mode: AppMode = .myPlacemarks {
    didSet {
      self.updateViewBasedOnMode()
    }
  }
  
  // MARK: - Actions
  
  func updateViewBasedOnMode() {
    switch self.mode {
    case .myPlacemarks:
      self.addButton.isHidden = false
      self.addButton.isUserInteractionEnabled = true
      self.listButton.isHidden = false
      self.listButton.isUserInteractionEnabled = true
      self.centerListButton.isHidden = true
      self.centerListButton.isUserInteractionEnabled = false
      self.modeButton.setImage(#imageLiteral(resourceName: "assetPlacemark"), for: .normal)
    case .foodNearby:
      self.addButton.isHidden = true
      self.addButton.isUserInteractionEnabled = false
      self.listButton.isHidden = true
      self.listButton.isUserInteractionEnabled = false
      self.centerListButton.isHidden = false
      self.centerListButton.isUserInteractionEnabled = true
      self.modeButton.setImage(#imageLiteral(resourceName: "assetForkKnife"), for: .normal)
    case .mountainViewer:
      self.addButton.isHidden = true
      self.addButton.isUserInteractionEnabled = false
      self.listButton.isHidden = true
      self.listButton.isUserInteractionEnabled = false
      self.centerListButton.isHidden = false
      self.centerListButton.isUserInteractionEnabled = true
      self.modeButton.setImage(#imageLiteral(resourceName: "assetMountains"), for: .normal)
    }
  }
  
  // MARK: - Actions
  
  @IBAction func settingsButtonSelected() {
    self.delegate?.tabButtonSelected(type: .settings, mode: self.mode)
  }
  
  @IBAction func addButtonSelected() {
    self.delegate?.tabButtonSelected(type: .add, mode: self.mode)
  }
  
  @IBAction func listButtonSelected() {
    self.delegate?.tabButtonSelected(type: .list, mode: self.mode)
  }
  
  @IBAction func modeButtonSelected() {
    self.delegate?.tabButtonSelected(type: .mode, mode: self.mode)
  }
}
