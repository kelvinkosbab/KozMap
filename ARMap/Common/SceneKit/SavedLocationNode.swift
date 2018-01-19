//
//  SavedLocationNode.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/26/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import SceneKit
import CoreLocation

class SavedLocationNode : Hashable {
  
  // MARK: - Hashable
  
  var hashValue: Int {
    return self.savedLocation.hashValue
  }
  
  // MARK: - Equatable
  
  static func ==(lhs: SavedLocationNode, rhs: SavedLocationNode) -> Bool {
    return lhs.savedLocation == rhs.savedLocation
  }
  
  // MARK: - Properties
  
  let savedLocation: SavedLocation
  weak var placemarkNode: PlacemarkNode? = nil
  
  init(savedLocation: SavedLocation, placemarkNode: PlacemarkNode? = nil) {
    self.savedLocation = savedLocation
    self.placemarkNode = placemarkNode
  }
  
  // MARK: - Node Types
  
  var isDefaultPlacemarkNode: Bool {
    if let _ = self.placemarkNode as? PinPlacemarkNode {
      return false
    } else if let _ = self.placemarkNode {
      return true
    }
    return false
  }
  
  var isPinPlacemarkNode: Bool {
    if let _ = self.placemarkNode as? PinPlacemarkNode {
      return true
    }
    return false
  }
  
  // MARK: - Node Content
  
  func refreshContent() {
    
    guard let placemarkNode = self.placemarkNode else {
      return
    }
    
    // Update name
    placemarkNode.primaryName = self.savedLocation.name
    
    // Distance and unit text
    let distanceAndUnitText = self.getDistanceAndUnitText(savedLocation: self.savedLocation)
    placemarkNode.distanceText = distanceAndUnitText.distanceText
    placemarkNode.unitText = distanceAndUnitText.unitText
    
    // Update the color
    if let color = self.savedLocation.color {
      placemarkNode.beamColor = color.color
    }
  }
  
  private func getDistanceAndUnitText(savedLocation: SavedLocation, unitType: UnitType = Defaults.shared.unitType) -> (distanceText: String?, unitText: String?) {
    let distanceText = savedLocation.lastDistance.getDistanceString(unitType: unitType, displayType: .numeric)
    let unitText = savedLocation.lastDistance.getDistanceString(unitType: unitType, displayType: .units(true))
    return (distanceText, unitText)
  }
}
