//
//  RoundedButton.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 4/28/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class RoundedButton : UIButton {
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.layer.cornerRadius = 8
    self.layer.masksToBounds = true
    self.clipsToBounds = true
  }
}

class PerfectRoundedButton : UIButton {
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.layer.cornerRadius = self.bounds.height / 2
    self.layer.masksToBounds = true
    self.clipsToBounds = true
  }
}
