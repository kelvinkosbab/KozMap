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
  
  private var defaultPlacemarkNode: PlacemarkNode? {
    didSet {
      if let defaultPlacemarkNode = self.defaultPlacemarkNode {
        self.baseWrapperNode = defaultPlacemarkNode
      }
    }
  }
  
  private var pinPlacemarkNode: PlacemarkNode? {
    didSet {
      if let pinPlacemarkNode = self.pinPlacemarkNode {
        self.baseWrapperNode = pinPlacemarkNode
      }
    }
  }
  
  private var beamPlacemarkNode: PlacemarkNode? {
    didSet {
      if let beamPlacemarkNode = self.beamPlacemarkNode {
        self.baseWrapperNode = beamPlacemarkNode
      }
    }
  }
  
  private var activePlacemarkNode: PlacemarkNode? {
    return self.defaultPlacemarkNode ?? self.pinPlacemarkNode ?? self.beamPlacemarkNode
  }
  
  private var scalableNode: SCNNode? {
    return self.activePlacemarkNode?.baseWrapperNode
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
  
  func update(currentScenePosition: SCNVector3, currentLocation: CLLocation, animated: Bool = true, duration: TimeInterval = 0.5, completion: (() -> Void)? = nil) {
    
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
      
      // Translated location
      let locationTranslation = currentLocation.translation(toLocation: strongSelf.savedLocation.location)
      
      if distance < closeDistanceCutoff {
        
        // Close distance
        
        // Scale it to be an appropriate size so that it can be seen
        let desiredNodeHeight: Float = 50 + Float(distance)
        let scale = desiredNodeHeight / strongSelf.boundingBox.max.y
        strongSelf.scalableNode?.scale = SCNVector3(x: scale, y: scale, z: scale)
        strongSelf.pivot = SCNMatrix4MakeTranslation(0, -1.1 * scale, 0)
        
        // Update the position
        let xPos = currentScenePosition.x + Float(locationTranslation.longitudeTranslation)
        let yPos = currentScenePosition.y + Float(locationTranslation.altitudeTranslation)
        let zPos = currentScenePosition.z - Float(locationTranslation.latitudeTranslation)
        let position = SCNVector3(
          x: xPos,
          y: abs(yPos) > 200 ? -(strongSelf.scalableNode?.boundingBox.max.y ?? 0) / 2 : yPos,
          z: zPos)
        let moveAction = SCNAction.move(to: position, duration: animated ? duration : 0)
        strongSelf.runAction(moveAction, completionHandler: completion)
        
      } else if distance >= closeDistanceCutoff && distance < mediumDistanceCutoff {
        
        // Medium distance
        let scaledDistance: Float = 30
        let desiredX = Float(locationTranslation.longitudeTranslation)
        let desiredY = Float(locationTranslation.altitudeTranslation)
        let desiredZ = Float(locationTranslation.latitudeTranslation)
        let scaleVector = SCNVector3(x: abs(scaledDistance / desiredX), y: abs(scaledDistance / desiredY), z: abs(scaledDistance / desiredZ))
        let scale = max(scaleVector.x, max(scaleVector.y, scaleVector.z))
        let position = SCNVector3(
          x: currentScenePosition.x + desiredX * scale,
          y: currentScenePosition.y + desiredY * scale,
          z: currentScenePosition.z - desiredZ * scale)
        let moveAction = SCNAction.move(to: position, duration: animated ? duration : 0)
        strongSelf.runAction(moveAction, completionHandler: completion)
        
        // Scale it to be an appropriate size so that it can be seen
        let desiredNodeHeight: Float = 100 + scale * Float(distance)
        let sizeScale = desiredNodeHeight / strongSelf.boundingBox.max.y
        let scaleAction = SCNAction.scale(to: CGFloat(sizeScale), duration: animated ? duration : 0)
        strongSelf.scalableNode?.runAction(scaleAction)
        strongSelf.pivot = SCNMatrix4MakeTranslation(0, -1.1 * sizeScale, 0)
        
        print("KAK-Med pos x:\(strongSelf.position.x) y:\(strongSelf.position.y) z:\(strongSelf.position.z)")
        print("KAK-Med max x:\(strongSelf.boundingBox.max.x) y:\(strongSelf.boundingBox.max.y) z:\(strongSelf.boundingBox.max.z)")
        
      } else if distance >= mediumDistanceCutoff {
        
        // Far distance
        let scaledDistance: Float = 30
        let desiredX = Float(locationTranslation.longitudeTranslation)
        let desiredY = Float(locationTranslation.altitudeTranslation)
        let desiredZ = Float(locationTranslation.latitudeTranslation)
        let scaleVector = SCNVector3(x: abs(scaledDistance / desiredX), y: abs(scaledDistance / desiredY), z: abs(scaledDistance / desiredZ))
        let scale = max(scaleVector.x, max(scaleVector.y, scaleVector.z))
        let position = SCNVector3(
          x: currentScenePosition.x + desiredX * scale,
          y: currentScenePosition.y + desiredY * scale,
          z: currentScenePosition.z - desiredZ * scale)
        let moveAction = SCNAction.move(to: position, duration: animated ? duration : 0)
        strongSelf.runAction(moveAction, completionHandler: completion)
        
        // Scale it to be an appropriate size so that it can be seen
        let desiredNodeHeight: Float = 100
        let sizeScale = desiredNodeHeight / strongSelf.boundingBox.max.y
        let scaleAction = SCNAction.scale(to: CGFloat(sizeScale), duration: animated ? duration : 0)
        strongSelf.scalableNode?.runAction(scaleAction)
        
        print("KAK-Far pos x:\(strongSelf.position.x) y:\(strongSelf.position.y) z:\(strongSelf.position.z)")
        print("KAK-Far max x:\(strongSelf.boundingBox.max.x) y:\(strongSelf.boundingBox.max.y) z:\(strongSelf.boundingBox.max.z)")
      }
    }
  }
}
