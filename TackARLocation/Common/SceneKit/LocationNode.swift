//
//  LocationNode.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import SceneKit

class VeritcalBeamNode : SCNNode {
  
  // MARK: - Properties and Init
  
  var savedLocation: SavedLocation? = nil
  
  init(savedLocation: SavedLocation) {
    self.savedLocation = savedLocation
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
