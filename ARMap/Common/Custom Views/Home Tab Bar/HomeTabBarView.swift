//
//  HomeTabBarView.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/7/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

enum HomeTabBarButtonType {
  case settings, mode
  case myPlacemarkList, myPlacemarkAdd
  case foodNearbyList, foodNearbyFavorites
  case mountainList
}

protocol HomeTabBarViewDelegate : class {
  func tabButtonSelected(type: HomeTabBarButtonType)
}

class HomeTabBarView : UIView {
  
  // MARK: - Static Accessors
  
  private static func newView() -> HomeTabBarView {
    return UINib(nibName: "HomeTabBarView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! HomeTabBarView
  }
  
  static func newView(appMode: AppMode, delegate: HomeTabBarViewDelegate?) -> HomeTabBarView {
    let view = self.newView()
    view.appMode = appMode
    view.delegate = delegate
    return view
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var farLeftButton: UIButton!
  @IBOutlet weak var centerLeftButton: UIButton!
  @IBOutlet weak var centerButton: UIButton!
  @IBOutlet weak var centerRightButton: UIButton!
  @IBOutlet weak var farRightButton: UIButton!
  
  weak var delegate: HomeTabBarViewDelegate? = nil
  
  var appMode: AppMode = .myPlacemarks {
    didSet {
      self.updateViewBasedOnMode()
    }
  }
  
  // MARK: - Actions
  
  func updateViewBasedOnMode() {
    switch self.appMode {
    case .myPlacemarks:
      self.centerLeftButton.setImage(#imageLiteral(resourceName: "assetList"), for: .normal)
      self.centerLeftButton.isHidden = false
      self.centerLeftButton.isUserInteractionEnabled = true
      self.centerRightButton.setImage(#imageLiteral(resourceName: "assetPlus"), for: .normal)
      self.centerRightButton.isHidden = false
      self.centerRightButton.isUserInteractionEnabled = true
      self.centerButton.isHidden = true
      self.centerButton.isUserInteractionEnabled = false
      self.farRightButton.setImage(#imageLiteral(resourceName: "assetPlacemark"), for: .normal)
    case .foodNearby:
      self.centerLeftButton.setImage(#imageLiteral(resourceName: "assetStar"), for: .normal)
      self.centerLeftButton.isHidden = false
      self.centerLeftButton.isUserInteractionEnabled = true
      self.centerRightButton.setImage(#imageLiteral(resourceName: "assetList"), for: .normal)
      self.centerRightButton.isHidden = false
      self.centerRightButton.isUserInteractionEnabled = true
      self.centerButton.isHidden = true
      self.centerButton.isUserInteractionEnabled = false
      self.farRightButton.setImage(#imageLiteral(resourceName: "assetForkKnife"), for: .normal)
    case .mountainViewer:
      self.centerLeftButton.isHidden = true
      self.centerLeftButton.isUserInteractionEnabled = false
      self.centerRightButton.isHidden = true
      self.centerRightButton.isUserInteractionEnabled = false
      self.centerButton.setImage(#imageLiteral(resourceName: "assetList"), for: .normal)
      self.centerButton.isHidden = false
      self.centerButton.isUserInteractionEnabled = true
      self.farRightButton.setImage(#imageLiteral(resourceName: "assetMountains"), for: .normal)
    }
  }
  
  // MARK: - Actions
  
  @IBAction func farLeftButtonSelected() {
    self.delegate?.tabButtonSelected(type: .settings)
  }
  
  @IBAction func centerLeftButtonSelected() {
    switch self.appMode {
    case .myPlacemarks:
      self.delegate?.tabButtonSelected(type: .myPlacemarkList)
    case .foodNearby:
      self.delegate?.tabButtonSelected(type: .foodNearbyFavorites)
    case .mountainViewer: break
    }
  }
  
  @IBAction func centerButtonSelected() {
    switch self.appMode {
    case .myPlacemarks: break
    case .foodNearby: break
    case .mountainViewer:
      self.delegate?.tabButtonSelected(type: .mountainList)
    }
  }
  
  @IBAction func centerRightButtonSelected() {
    switch self.appMode {
    case .myPlacemarks:
      self.delegate?.tabButtonSelected(type: .myPlacemarkAdd)
    case .foodNearby:
      self.delegate?.tabButtonSelected(type: .foodNearbyList)
    case .mountainViewer: break
    }
  }
  
  @IBAction func farRightButtonSelected() {
    self.delegate?.tabButtonSelected(type: .mode)
  }
}
