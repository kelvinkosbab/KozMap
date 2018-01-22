//
//  PlacemarkNodeContainer.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/26/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import SceneKit
import CoreLocation

class PlacemarkNodeContainer : Hashable {
  
  // MARK: - Hashable
  
  var hashValue: Int {
    return self.placemark.hashValue
  }
  
  // MARK: - Equatable
  
  static func ==(lhs: PlacemarkNodeContainer, rhs: PlacemarkNodeContainer) -> Bool {
    return lhs.placemark == rhs.placemark
  }
  
  // MARK: - Properties
  
  let placemark: Placemark
  weak var placemarkNode: PlacemarkNode? = nil
  
  init(placemark: Placemark, placemarkNode: PlacemarkNode? = nil) {
    self.placemark = placemark
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
    placemarkNode.primaryName = self.placemark.name
    
    // Distance and unit text
    let distanceAndUnitText = self.getDistanceAndUnitText(placemark: self.placemark)
    placemarkNode.distanceText = distanceAndUnitText.distanceText
    placemarkNode.unitText = distanceAndUnitText.unitText
    
    // Update the color
    if let color = self.placemark.color {
      placemarkNode.beamColor = color.color
    }
  }
  
  private func getDistanceAndUnitText(placemark: Placemark, unitType: UnitType = Defaults.shared.unitType) -> (distanceText: String?, unitText: String?) {
    let distanceText = placemark.lastDistance.getDistanceString(unitType: unitType, displayType: .numeric)
    let unitText = placemark.lastDistance.getDistanceString(unitType: unitType, displayType: .units(true))
    return (distanceText, unitText)
  }
}
