//
//  LocationListViewController+Cells.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit

class LocationListViewControllerCell : UITableViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var detailLabel: UILabel!
  @IBOutlet weak var colorView: UIView!
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if self.colorView.layer.cornerRadius != 20 {
      self.colorView.layer.cornerRadius = 20
      self.colorView.layer.masksToBounds = true
      self.colorView.clipsToBounds = true
    }
  }
  
  func configure(savedLocation: SavedLocation) {
    
    // Saved location
    self.titleLabel.text = savedLocation.name ?? "Unnamed"
    
    // Distance labels
    if savedLocation.hasLastDistance {
      let readibleDistance = savedLocation.lastDistance.getBasicReadibleDistance(unitType: Defaults.shared.unitType)
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
}
