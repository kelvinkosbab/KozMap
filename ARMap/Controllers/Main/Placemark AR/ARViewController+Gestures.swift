//
//  ARViewController+Gestures.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 1/10/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

extension ARViewController {
  
  func startListeningForGestures() {
    
    // Tap gesture
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.screenTapped(_:)))
    self.sceneView.addGestureRecognizer(tapGestureRecognizer)
  }
  
  @objc private func screenTapped(_ tapRecognizer: UITapGestureRecognizer) {
    let tappedLocation = tapRecognizer.location(in: self.sceneView)
    let hitResults = self.sceneView.hitTest(tappedLocation, options: [:])
    
    // Check if the user tapped a placemark : Hierarchy = (*.scn contents) > VirtualObject Wrapper Node > PlacemarkNode
    if let placemarkNode = hitResults.first?.node.parent?.parent as? PlacemarkNode, let savedLocationNode = self.placemarks.first(where: { $0.placemarkNode == placemarkNode }) {
      self.delegate?.userDidTap(savedLocation: savedLocationNode.savedLocation)
    }
  }
}
