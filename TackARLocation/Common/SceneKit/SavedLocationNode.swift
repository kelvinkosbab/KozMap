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
  
  func update(currentScenePosition: SCNVector3, currentLocation: CLLocation, animated: Bool = true, duration: TimeInterval = 0.1, completion: (() -> Void)? = nil) {
    
    // Distance to the saved location object
    let distance = self.savedLocation.location.distance(from: currentLocation)
    
    // Update the active placemark node
    let dispatchGroup = DispatchGroup()
    let closeDistanceCutoff: Double = 100
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
        completion?()
        return
      }
      
      let locationTranslation = currentLocation.translation(toLocation: strongSelf.savedLocation.location)
      let adjustedDistance: CLLocationDistance
      SCNTransaction.begin()
      
      SCNTransaction.completionBlock = completion
      
      if animated {
        SCNTransaction.animationDuration = duration
      } else {
        SCNTransaction.animationDuration = 0
      }
      
      if distance < closeDistanceCutoff {
      } else if distance >= closeDistanceCutoff && distance < mediumDistanceCutoff {
      } else if distance >= mediumDistanceCutoff {
      }
      
      if distance > 1000 {
        
        //If the item is too far away, bring it closer and scale it down
        let scale = 100 / Float(distance)
        adjustedDistance = distance * Double(scale)
        
        let adjustedTranslation = SCNVector3(
          x: Float(locationTranslation.longitudeTranslation) * scale,
          y: Float(locationTranslation.altitudeTranslation) * scale,
          z: Float(locationTranslation.latitudeTranslation) * scale)
        
        let yOffset: Float = strongSelf.activePlacemarkNode?.boundingBox.max.y ?? 50
        let position = SCNVector3(
          x: currentScenePosition.x + adjustedTranslation.x,
          y: currentScenePosition.y + adjustedTranslation.y - yOffset,
          z: currentScenePosition.z - adjustedTranslation.z)
        
        strongSelf.position = position
        strongSelf.scale = SCNVector3(x: scale, y: scale, z: scale)
        
      } else {
        
        let yOffset: Float = strongSelf.activePlacemarkNode?.boundingBox.max.y ?? 50 / 4
        adjustedDistance = distance
        let position = SCNVector3(
          x: currentScenePosition.x + Float(locationTranslation.longitudeTranslation),
          y: currentScenePosition.y + Float(locationTranslation.altitudeTranslation) - yOffset,
          z: currentScenePosition.z - Float(locationTranslation.latitudeTranslation))
        
        strongSelf.position = position
        strongSelf.scale = SCNVector3(x: 1, y: 1, z: 1)
      }
      
      //The scale of a node with a billboard constraint applied is ignored
      //The annotation subnode itself, as a subnode, has the scale applied to it
      let appliedScale = strongSelf.scale
      strongSelf.scale = SCNVector3(x: 1, y: 1, z: 1)
      
      var scale: Float
      if strongSelf.scaleRelativeToDistance {
        scale = appliedScale.y
        strongSelf.scalableNode?.scale = appliedScale
      } else {
        
        //Scale it to be an appropriate size so that it can be seen
        scale = Float(adjustedDistance) * 0.181
        
        if distance > 3000 {
          scale = scale * 0.75
        }
        strongSelf.scalableNode?.scale = SCNVector3(x: scale, y: scale, z: scale)
      }
      
      strongSelf.pivot = SCNMatrix4MakeTranslation(0, -1.1 * scale, 0)
      
      SCNTransaction.commit()
    }
  }
  
  // MARK: - KAK TO REFACTOR
  
  ///Subnodes and adjustments should be applied to this subnode
  ///Required to allow scaling at the same time as having a 2D 'billboard' appearance
  var scalableNode: SCNNode? {
    return self.baseWrapperNode
  }
  
  ///Whether a node's position should be adjusted on an ongoing basis
  ///based on its' given location.
  ///This only occurs when a node's location is within 100m of the user.
  ///Adjustment doesn't apply to nodes without a confirmed location.
  ///When this is set to false, the result is a smoother appearance.
  ///When this is set to true, this means a node may appear to jump around
  ///as the user's location estimates update,
  ///but the position is generally more accurate.
  ///Defaults to true.
  public var continuallyAdjustNodePositionWhenWithinRange = true
  
  ///Whether the node should be scaled relative to its distance from the camera
  ///Default value (false) scales it to visually appear at the same size no matter the distance
  ///Setting to true causes annotation nodes to scale like a regular node
  ///Scaling relative to distance may be useful with local navigation-based uses
  ///For landmarks in the distance, the default is correct
  public var scaleRelativeToDistance = true
}
