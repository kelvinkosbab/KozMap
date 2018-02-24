//
//  TextFlagPlacemarkNode.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 2/23/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import SceneKit

class TextFlagPlacemarkNode : PlacemarkNode {
  
  override var modelName: String {
    return "TextFlagPlacemarkNode"
  }
  
  // MARK: - Init
  
  override init() {
    super.init()
    self.nameTextAlignment = .left(0.05)
    self.distanceTextAlignment = .left(0.05)
    self.unitTextTextAlignment = .left(0.05)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
