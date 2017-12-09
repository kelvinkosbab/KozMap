//
//  SavedLocationNode.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/26/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import SceneKit
import CoreLocation

class SavedLocationNode : VirtualObject {
  
  // MARK: - Properties
  
  let savedLocation: SavedLocation
  
  private var defaultPlacemarkNode: PlacemarkNode?
  private var pinPlacemarkNode: PlacemarkNode?
  private var beamPlacemarkNode: PlacemarkNode?
  
  private var activePlacemarkNode: PlacemarkNode? {
    return self.defaultPlacemarkNode ?? self.pinPlacemarkNode ?? self.beamPlacemarkNode
  }
  
  // MARK: - Init
  init(savedLocation: SavedLocation) {
    self.savedLocation = savedLocation
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Content
  
  func refreshContent() {
    
    guard let placemark = self.activePlacemarkNode else {
      return
    }
    
    // Update name
    if placemark.primaryName != savedLocation.name {
      placemark.primaryName = savedLocation.name
    }
    
    // Distance and unit text
    let distanceAndUnitText = self.getDistanceAndUnitText(savedLocation: savedLocation)
    
    // Update distance text
    if placemark.distanceText != distanceAndUnitText.distanceText {
      placemark.distanceText = distanceAndUnitText.distanceText
    }
    
    // Update unit text
    if placemark.unitText != distanceAndUnitText.unitText {
      placemark.unitText = distanceAndUnitText.unitText
    }
    
    // Update the color
    if let color = savedLocation.color {
      placemark.beamColor = color.color
    }
  }
  
  private func getDistanceAndUnitText(savedLocation: SavedLocation, unitType: UnitType = Defaults.shared.unitType) -> (distanceText: String?, unitText: String?) {
    let distanceText = savedLocation.lastDistance.getDistanceString(unitType: unitType, displayType: .numeric)
    let unitText = savedLocation.lastDistance.getDistanceString(unitType: unitType, displayType: .units(true))
    return (distanceText, unitText)
  }
  
  func update(currentScenePosition: SCNVector3, currentLocation: CLLocation) {
    
    // Distance to the saved location object
    let distance = self.savedLocation.location.distance(from: currentLocation)
    
    // Update the active placemark node
    let dispatchGroup = DispatchGroup()
    let closeDistanceCutoff: Double = 400 // 400 meters = 0.25 miles
    let mediumDistanceCutoff: Double = 8000 // 8000 meters = 5 miles
    if distance < closeDistanceCutoff && self.defaultPlacemarkNode == nil {
      dispatchGroup.enter()
      let defaultPlacemarkNode = PlacemarkNode()
      defaultPlacemarkNode.loadModel { [weak self] in
        self?.pinPlacemarkNode = nil
        self?.beamPlacemarkNode = nil
        self?.enumerateChildNodes { (node, _) in
          node.removeFromParentNode()
        }
        self?.defaultPlacemarkNode = defaultPlacemarkNode
        self?.addChildNode(defaultPlacemarkNode)
        self?.refreshContent()
        dispatchGroup.leave()
      }
      
    } else if distance >= closeDistanceCutoff && distance < mediumDistanceCutoff && self.pinPlacemarkNode == nil {
      dispatchGroup.enter()
      let pinPlacemarkNode = PinPlacemarkNode()
      pinPlacemarkNode.loadModel { [weak self] in
        self?.defaultPlacemarkNode = nil
        self?.beamPlacemarkNode = nil
        self?.enumerateChildNodes { (node, _) in
          node.removeFromParentNode()
        }
        self?.pinPlacemarkNode = pinPlacemarkNode
        self?.addChildNode(pinPlacemarkNode)
        self?.refreshContent()
        dispatchGroup.leave()
      }
      
    } else if distance >= mediumDistanceCutoff && self.beamPlacemarkNode == nil {
      dispatchGroup.enter()
      let beamPlacemarkNode = BeamPlacemarkNode()
      beamPlacemarkNode.loadModel { [weak self] in
        self?.defaultPlacemarkNode = nil
        self?.pinPlacemarkNode = nil
        self?.enumerateChildNodes { (node, _) in
          node.removeFromParentNode()
        }
        self?.beamPlacemarkNode = beamPlacemarkNode
        self?.addChildNode(beamPlacemarkNode)
        self?.refreshContent()
        dispatchGroup.leave()
      }
    }
    
    // Wait until the active placemark node has been set
    dispatchGroup.notify(queue: .main) { [weak self] in
      
      guard let strongSelf = self else {
        return
      }
      
      let locationTranslation = currentLocation.translation(toLocation: strongSelf.savedLocation.location)
      
      if distance < closeDistanceCutoff {
        
        // Close distance
        let position = SCNVector3(
          x: currentScenePosition.x + Float(locationTranslation.longitudeTranslation),
          y: currentScenePosition.y + Float(locationTranslation.altitudeTranslation),
          z: currentScenePosition.z - Float(locationTranslation.latitudeTranslation))
        strongSelf.position = position
        
        // Scale it to be an appropriate size so that it can be seen
        strongSelf.scale = SCNVector3(x: 1, y: 1, z: 1)
        if let activePlacemarkNode = strongSelf.activePlacemarkNode {
          let desiredNodeHeight: Float = 50
          let scale = desiredNodeHeight / activePlacemarkNode.boundingBox.max.y
          activePlacemarkNode.scale = SCNVector3(x: scale, y: scale, z: scale)
          strongSelf.pivot = SCNMatrix4MakeTranslation(0, -1.1 * scale, 0)
        }
        
      } else if distance >= closeDistanceCutoff && distance < mediumDistanceCutoff {
        
        // Medium distance
        let scale = Float(distance) * Float((distance - closeDistanceCutoff) / (mediumDistanceCutoff - closeDistanceCutoff))
        let adjustedTranslation = SCNVector3(
          x: Float(locationTranslation.longitudeTranslation) * scale / 100,
          y: Float(locationTranslation.altitudeTranslation) * scale / 100,
          z: Float(locationTranslation.latitudeTranslation) * scale / 100)
        let position = SCNVector3(
          x: currentScenePosition.x + adjustedTranslation.x,
          y: currentScenePosition.y + adjustedTranslation.y,
          z: currentScenePosition.z - adjustedTranslation.z)
        strongSelf.position = position
        
        // Scale it to be an appropriate size so that it can be seen
//        let scale = Float(distance) * 0.181
//        let scale = Float(distance) * Float((distance - closeDistanceCutoff) / (mediumDistanceCutoff - closeDistanceCutoff)) / 10
        strongSelf.scale = SCNVector3(x: 1, y: 1, z: 1)
        strongSelf.activePlacemarkNode?.scale = SCNVector3(x: scale / 10, y: scale / 10, z: scale / 10)
        strongSelf.pivot = SCNMatrix4MakeTranslation(0, -1.1 * scale / 10, 0)
        
      } else if distance >= mediumDistanceCutoff {

        // Far distance
        let positionScale: Float = 100 / Float(distance)
        let adjustedTranslation = SCNVector3(
          x: Float(locationTranslation.longitudeTranslation) * positionScale,
          y: Float(locationTranslation.altitudeTranslation) * positionScale,
          z: Float(locationTranslation.latitudeTranslation) * positionScale)
        let position = SCNVector3(
          x: currentScenePosition.x + adjustedTranslation.x,
          y: currentScenePosition.y + adjustedTranslation.y,
          z: currentScenePosition.z - adjustedTranslation.z)
        strongSelf.position = position
        
        // Scale it to be an appropriate size so that it can be seen
        strongSelf.scale = SCNVector3(x: 1, y: 1, z: 1)
        strongSelf.activePlacemarkNode?.scale = SCNVector3(x: positionScale, y: positionScale, z: positionScale)
        strongSelf.pivot = SCNMatrix4MakeTranslation(0, -1.1 * positionScale, 0)
      }
      
      
//      let adjustedDistance: CLLocationDistance
//      if distance > 1000 {
//
//        //If the item is too far away, bring it closer and scale it down
//        let scale = 100 / Float(distance)
//        adjustedDistance = distance * Double(scale)
//
//        let adjustedTranslation = SCNVector3(
//          x: Float(locationTranslation.longitudeTranslation) * scale,
//          y: Float(locationTranslation.altitudeTranslation) * scale,
//          z: Float(locationTranslation.latitudeTranslation) * scale)
//
//        let yOffset: Float = strongSelf.activePlacemarkNode?.boundingBox.max.y ?? 50
//        let position = SCNVector3(
//          x: currentScenePosition.x + adjustedTranslation.x,
//          y: currentScenePosition.y + adjustedTranslation.y - yOffset,
//          z: currentScenePosition.z - adjustedTranslation.z)
//
//        strongSelf.position = position
//        strongSelf.scale = SCNVector3(x: scale, y: scale, z: scale)
//
//      } else {
//
//        let yOffset: Float = strongSelf.activePlacemarkNode?.boundingBox.max.y ?? 50 / 4
//        adjustedDistance = distance
////        let position = SCNVector3(
////          x: currentScenePosition.x + Float(locationTranslation.longitudeTranslation),
////          y: currentScenePosition.y + Float(locationTranslation.altitudeTranslation) - yOffset,
////          z: currentScenePosition.z - Float(locationTranslation.latitudeTranslation))
//
//        let position = SCNVector3(
//          x: currentScenePosition.x + Float(locationTranslation.longitudeTranslation),
//          y: 0 - yOffset,
//          z: currentScenePosition.z - Float(locationTranslation.latitudeTranslation))
//
//        strongSelf.position = position
//        strongSelf.scale = SCNVector3(x: 1, y: 1, z: 1)
//      }
//
//      //The scale of a node with a billboard constraint applied is ignored
//      //The annotation subnode itself, as a subnode, has the scale applied to it
//      let appliedScale = strongSelf.scale
//      strongSelf.scale = SCNVector3(x: 1, y: 1, z: 1)
//
//      var scale: Float
//      if strongSelf.scaleRelativeToDistance {
//        scale = appliedScale.y
//        strongSelf.activePlacemarkNode?.scale = appliedScale
//      } else {
//
//        //Scale it to be an appropriate size so that it can be seen
//        scale = Float(adjustedDistance) * 0.181
//
//        if distance > 3000 {
//          scale = scale * 0.75
//        }
//        strongSelf.activePlacemarkNode?.scale = SCNVector3(x: scale, y: scale, z: scale)
//      }
//
//      strongSelf.pivot = SCNMatrix4MakeTranslation(0, -1.1 * scale, 0)
      
      print("KAK pos x:\(strongSelf.position.x) y:\(strongSelf.position.y) z:\(strongSelf.position.z)")
      print("KAK max x:\(strongSelf.boundingBox.max.x) y:\(strongSelf.boundingBox.max.y) z:\(strongSelf.boundingBox.max.z)")
    }
  }
  
  // MARK: - KAK TO REFACTOR
  
  ///Whether the node should be scaled relative to its distance from the camera
  ///Default value (false) scales it to visually appear at the same size no matter the distance
  ///Setting to true causes annotation nodes to scale like a regular node
  ///Scaling relative to distance may be useful with local navigation-based uses
  ///For landmarks in the distance, the default is correct
  public var scaleRelativeToDistance = false
}
