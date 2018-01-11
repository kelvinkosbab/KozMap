//
//  LocationListViewController+Cells.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit

protocol LocationListViewControllerCellDelegate : class {
  func moreButtonSelected(savedLocation: SavedLocation, sender: UIView)
}

class LocationListViewControllerCell : UITableViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var detailLabel: UILabel!
  @IBOutlet weak var colorView: UIView!
  @IBOutlet weak var moreButton: UIButton!
  private weak var savedLocation: SavedLocation? = nil
  weak var delegate: LocationListViewControllerCellDelegate? = nil
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if self.colorView.layer.cornerRadius != 20 {
      self.colorView.layer.cornerRadius = 20
      self.colorView.layer.masksToBounds = true
      self.colorView.clipsToBounds = true
    }
  }
  
  func configure(savedLocation: SavedLocation, unitType: UnitType, delegate: LocationListViewControllerCellDelegate?) {
    
    // Delegate
    self.delegate = delegate
    
    // Saved location
    self.savedLocation = savedLocation
    self.titleLabel.text = savedLocation.name ?? "Unnamed"
    
    // Distance labels
    if let readibleDistance = savedLocation.lastDistance.getDistanceString(unitType: unitType, displayType: .numbericUnits(false))?.lowercased() {
      self.detailLabel.text = "\(readibleDistance) away"
    } else {
      let roundedLatitude = Double(round(savedLocation.latitude*1000)/1000)
      let roundedLongitude = Double(round(savedLocation.longitude*1000)/1000)
      self.detailLabel.text = "\(roundedLatitude)°N, \(roundedLongitude)°W"
    }
    
    // Color view
    if let color = savedLocation.color {
      self.colorView.backgroundColor = color.color
    } else {
      self.colorView.backgroundColor = .kozRed
    }
  }
  
  @IBAction func moreButtonSelected(_ sender: UIView) {
    if let savedLocation = self.savedLocation {
      self.delegate?.moreButtonSelected(savedLocation: savedLocation, sender: sender)
    }
  }
}
