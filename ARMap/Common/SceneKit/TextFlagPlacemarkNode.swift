//
//  TextFlagPlacemarkNode.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 2/23/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import SceneKit

class TextFlagPlacemarkNode : PlacemarkNode {
  
  override var modelName: String {
    return "TextFlagPlacemarkNode"
  }
  
  // MARK: - Init
  
  override init() {
    super.init()
    
    // Alighnment
    self.nameTextAlignment = .left(0.05)
    self.distanceTextAlignment = .left(0.05)
    self.unitTextTextAlignment = .left(0.05)
    
    // Day / Night
    self.nameTextRespondsToDayNight = true
    self.distanceTextRespondsToDayNight = true
    self.unitTextRespondsToDayNight = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
