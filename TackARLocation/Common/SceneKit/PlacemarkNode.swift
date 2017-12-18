//
//  PlacemarkNode.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 11/1/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import SceneKit
import CoreLocation

class PlacemarkNode : VirtualObject {
  
  override var modelName: String {
    return "PlacemarkNode"
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
    
    let billboardConstraint = SCNBillboardConstraint()
    billboardConstraint.freeAxes = .Y
    self.constraints = [ billboardConstraint ]
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Child Nodes
  
  private var nameTextNode: SCNNode? {
    return self.childNode(withName: "nameText", recursively: true)
  }
  
  private var distanceTextNode: SCNNode? {
    return self.childNode(withName: "distanceText", recursively: true)
  }
  
  private var unitTextNode: SCNNode? {
    return self.childNode(withName: "unitText", recursively: true)
  }
  
  private var beamNode: SCNNode? {
    return self.childNode(withName: "beam", recursively: true)
  }
  
  private var bottomPyramidNode: SCNNode? {
    return self.childNode(withName: "pyramid1", recursively: true)
  }
  
  private var middlePyramidNode: SCNNode? {
    return self.childNode(withName: "pyramid2", recursively: true)
  }
  
  private var topPyramidNode: SCNNode? {
    return self.childNode(withName: "pyramid3", recursively: true)
  }
  
  private func updatePrimaryName() {
    if let textGeometry = self.nameTextNode?.geometry as? SCNText {
      textGeometry.string = self.primaryName
    }
  }
  
  private func updateDistanceText() {
    if let textGeometry = self.distanceTextNode?.geometry as? SCNText {
      textGeometry.string = self.distanceText
    }
  }
  
  private func updateUnitText() {
    if let textGeometry = self.unitTextNode?.geometry as? SCNText {
      textGeometry.string = self.unitText
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
