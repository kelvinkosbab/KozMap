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
    
    self.colorView.layer.cornerRadius = 20
    self.colorView.layer.masksToBounds = true
    self.colorView.clipsToBounds = true
  }
}
