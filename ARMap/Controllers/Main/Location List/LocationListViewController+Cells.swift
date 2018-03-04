//
//  LocationListViewController+Cells.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

protocol LocationListViewControllerCellDelegate : class {
  func moreButtonSelected(placemark: Placemark, sender: UIView)
}

class LocationListViewControllerCell : UITableViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var detailLabel: UILabel!
  @IBOutlet weak var colorView: UIView!
  @IBOutlet weak var moreButton: UIButton!
  private weak var placemark: Placemark? = nil
  weak var delegate: LocationListViewControllerCellDelegate? = nil
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if self.colorView.layer.cornerRadius != 20 {
      self.colorView.layer.cornerRadius = 20
      self.colorView.layer.masksToBounds = true
      self.colorView.clipsToBounds = true
    }
  }
  
  func configure(placemark: Placemark, unitType: UnitType, delegate: LocationListViewControllerCellDelegate?, hideMoreButton: Bool) {
    
    // Delegate
    self.delegate = delegate
    
    // Saved location
    self.placemark = placemark
    self.titleLabel.text = placemark.name ?? "Unnamed"
    
    // Distance labels
    if let readibleDistance = placemark.lastDistance.getDistanceString(unitType: unitType, displayType: .numbericUnits(false))?.lowercased() {
      self.detailLabel.text = "\(readibleDistance) away"
    } else {
      let roundedLatitude = Double(round(placemark.latitude*1000)/1000)
      let roundedLongitude = Double(round(placemark.longitude*1000)/1000)
      self.detailLabel.text = "\(roundedLatitude)°N, \(roundedLongitude)°W"
    }
    
    // Color view
    if let color = placemark.color {
      self.colorView.backgroundColor = color.color
    } else {
      self.colorView.backgroundColor = .kozRed
    }
    
    // More button
    self.moreButton.isUserInteractionEnabled = !hideMoreButton
    self.moreButton.isHidden = hideMoreButton
  }
  
  @IBAction func moreButtonSelected(_ sender: UIView) {
    if let placemark = self.placemark {
      self.delegate?.moreButtonSelected(placemark: placemark, sender: sender)
    }
  }
}
