//
//  PlacemarkNode.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 11/1/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import SceneKit
import CoreLocation

class PlacemarkNode : VirtualObject {
  
  override var modelName: String {
    return "PlacemarkNode"
  }
  
  // MARK: - Text Alignment
  
  internal var nameTextAlignment: SCNTextAlignment? = nil
  internal var distanceTextAlignment: SCNTextAlignment? = nil
  internal var unitTextTextAlignment: SCNTextAlignment? = nil
  
  internal var nameTextRespondsToDayNight: Bool = false
  internal var distanceTextRespondsToDayNight: Bool = false
  internal var unitTextRespondsToDayNight: Bool = false
  
  // MARK: - Init
  
  convenience init(primaryName: String? = nil, distanceText: String? = nil, unitText: String? = nil, beamColor: UIColor = .kozRed, beamTransparency: CGFloat = 0.7) {
    self.init()
    self.primaryName = primaryName
    self.distanceText = distanceText
    self.unitText = unitText
    self.beamColor = beamColor
    self.beamTransparency = beamTransparency
  }
  
  override init() {
    super.init()
    
    // Set up bilboard constraint so always facing user
    let billboardConstraint = SCNBillboardConstraint()
    billboardConstraint.freeAxes = .Y
    self.constraints = [ billboardConstraint ]
    
    // Text alignment properties
    self.nameTextAlignment = nil
    self.distanceTextAlignment = .center
    self.unitTextTextAlignment = .center
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Properties
  
  var scalableNode: SCNNode? {
    return self.baseWrapperNode
  }
  
  var primaryName: String? = nil {
    didSet {
      self.updatePrimaryName()
    }
  }
  
  var distanceText: String? = nil {
    didSet {
      self.updateDistanceText()
    }
  }
  
  var unitText: String? = nil {
    didSet {
      self.updateUnitText()
    }
  }
  
  var beamColor: UIColor = .kozRed {
    didSet {
      self.updateBeamColor()
    }
  }
  
  var beamTransparency: CGFloat = 0.7 {
    didSet {
      self.updateBeamTransparency()
    }
  }
  
  // MARK: - Child Nodes
  
  final internal var nameTextNode: SCNNode? {
    return self.childNode(withName: "nameText", recursively: true)
  }
  
  final internal var distanceTextNode: SCNNode? {
    return self.childNode(withName: "distanceText", recursively: true)
  }
  
  final internal var unitTextNode: SCNNode? {
    return self.childNode(withName: "unitText", recursively: true)
  }
  
  final internal var beamNode: SCNNode? {
    return self.childNode(withName: "beam", recursively: true)
  }
  
  final internal var bottomPyramidNode: SCNNode? {
    return self.childNode(withName: "pyramid1", recursively: true)
  }
  
  final internal var middlePyramidNode: SCNNode? {
    return self.childNode(withName: "pyramid2", recursively: true)
  }
  
  final internal var topPyramidNode: SCNNode? {
    return self.childNode(withName: "pyramid3", recursively: true)
  }
  
  internal func updatePrimaryName() {
    
    // Update text
    if let textGeometry = self.nameTextNode?.geometry as? SCNText, textGeometry.string as? String != self.primaryName {
      textGeometry.alignmentMode = kCAAlignmentCenter
      textGeometry.string = self.primaryName
    }
    
    // Day / Night
    if let textGeometry = self.nameTextNode?.geometry as? SCNText, self.nameTextRespondsToDayNight {
      textGeometry.firstMaterial?.diffuse.contents = DayNight.isNight ? UIColor.white : UIColor.black
    }
    
    // Adjustments for text alignment
    if let nameTextAlignment = self.nameTextAlignment {
      switch nameTextAlignment {
      case .left(let xOffset): // Left align the text
        if let nameTextNode = self.nameTextNode {
          nameTextNode.position = SCNVector3(x: xOffset, y: nameTextNode.position.y, z: nameTextNode.position.z)
        }
      case .center: // Center the node on the x-axis
        if let nameTextNode = self.nameTextNode {
          let dx = -(nameTextNode.boundingBox.max.x - nameTextNode.boundingBox.min.x) * nameTextNode.scale.x / 2
          nameTextNode.position = SCNVector3(x: dx, y: nameTextNode.position.y, z: nameTextNode.position.z)
        }
      }
    }
  }
  
  internal func updateDistanceText() {
    
    // Update text
    if let textGeometry = self.distanceTextNode?.geometry as? SCNText, textGeometry.string as? String != self.distanceText {
      textGeometry.alignmentMode = kCAAlignmentCenter
      textGeometry.string = self.distanceText
    }
    
    // Day / Night
    if let textGeometry = self.distanceTextNode?.geometry as? SCNText, self.distanceTextRespondsToDayNight {
      textGeometry.firstMaterial?.diffuse.contents = DayNight.isNight ? UIColor.white : UIColor.black
    }
    
    // Adjustments for text alignment
    if let distanceTextAlignment = self.distanceTextAlignment {
      switch distanceTextAlignment {
      case .left(let xOffset): // Left align the text
        if let distanceTextNode = self.distanceTextNode {
          distanceTextNode.position = SCNVector3(x: xOffset, y: distanceTextNode.position.y, z: distanceTextNode.position.z)
        }
      case .center: // Center the node on the x-axis
        if let distanceTextNode = self.distanceTextNode {
          let dx = -(distanceTextNode.boundingBox.max.x - distanceTextNode.boundingBox.min.x) * distanceTextNode.scale.x / 2
          distanceTextNode.position = SCNVector3(x: dx, y: distanceTextNode.position.y, z: distanceTextNode.position.z)
        }
      }
    }
  }
  
  internal func updateUnitText() {
    
    // Update text
    if let textGeometry = self.unitTextNode?.geometry as? SCNText, textGeometry.string as? String != self.unitText {
      textGeometry.alignmentMode = kCAAlignmentCenter
      textGeometry.string = self.unitText
    }
    
    // Day / Night
    if let textGeometry = self.unitTextNode?.geometry as? SCNText, self.unitTextRespondsToDayNight {
      textGeometry.firstMaterial?.diffuse.contents = DayNight.isNight ? UIColor.white : UIColor.black
    }
    
    // Adjustments for text alignment
    if let unitTextTextAlignment = self.unitTextTextAlignment {
      switch unitTextTextAlignment {
      case .left(let xOffset): // Left align the text
        if let unitTextNode = self.unitTextNode {
          unitTextNode.position = SCNVector3(x: xOffset, y: unitTextNode.position.y, z: unitTextNode.position.z)
        }
      case .center: // Center the node on the x-axis
        if let unitTextNode = self.unitTextNode {
          let dx = -(unitTextNode.boundingBox.max.x - unitTextNode.boundingBox.min.x) * unitTextNode.scale.x / 2
          unitTextNode.position = SCNVector3(x: dx, y: unitTextNode.position.y, z: unitTextNode.position.z)
        }
      }
    }
  }
  
  internal func updateBeamColor() {
    self.beamNode?.geometry?.firstMaterial?.diffuse.contents = self.beamColor
    self.topPyramidNode?.geometry?.firstMaterial?.diffuse.contents = self.beamColor
    self.middlePyramidNode?.geometry?.firstMaterial?.diffuse.contents = self.beamColor
    self.bottomPyramidNode?.geometry?.firstMaterial?.diffuse.contents = self.beamColor
  }
  
  internal func updateBeamTransparency() {
    self.beamNode?.geometry?.firstMaterial?.transparency = self.beamTransparency
    self.topPyramidNode?.geometry?.firstMaterial?.transparency = self.beamTransparency
    self.middlePyramidNode?.geometry?.firstMaterial?.transparency = self.beamTransparency * 2 / 3
    self.bottomPyramidNode?.geometry?.firstMaterial?.transparency = self.beamTransparency * 1 / 3
  }
  
  // MARK: - Load Model
  
  override func loadModel(completion: @escaping () -> Void) {
    super.loadModel { [weak self] in
      
      // Update labels
      self?.updatePrimaryName()
      self?.updateDistanceText()
      self?.updateUnitText()
      self?.updateBeamColor()
      self?.updateBeamTransparency()
      
      // Completion
      completion()
    }
  }
}
