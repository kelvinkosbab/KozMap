//
//  PlacemarkNode.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 11/1/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import SceneKit
import CoreLocation

class PlacemarkNode : VirtualObject, Locatible {
  
  // MARK: - Locatible
  
  var location: CLLocation? = nil
  
  // MARK: - Properties
  
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
  
  var beamColor: UIColor = .cyan {
    didSet {
      self.updateBeamColor()
    }
  }
  
  var beamTransparency: CGFloat = 1 {
    didSet {
      self.updateBeamTransparency()
    }
  }
  
  // MARK: - Init
  
  convenience init(location: CLLocation, primaryName: String? = nil, distanceText: String? = nil, unitText: String? = nil, beamColor: UIColor = .cyan, beamTransparency: CGFloat = 1) {
    self.init()
    self.location = location
    self.primaryName = primaryName
    self.distanceText = distanceText
    self.unitText = unitText
    self.beamColor = beamColor
    self.beamTransparency = beamTransparency
  }
  
  init() {
    super.init(modelName: "PlacemarkNode", fileExtension: "scn")
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
  
  private func updateBeamColor() {
    self.beamNode?.geometry?.firstMaterial?.diffuse.contents = self.beamColor
  }
  
  private func updateBeamTransparency() {
    self.beamNode?.geometry?.firstMaterial?.transparency = self.beamTransparency
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
  
  // MARK: - KAK TO REFACTOR
  
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
  public var scaleRelativeToDistance = false
}

class BillboardPlacemarkNode : PlacemarkNode {
  
  ///Subnodes and adjustments should be applied to this subnode
  ///Required to allow scaling at the same time as having a 2D 'billboard' appearance
  var billboardAnnotationNode: SCNNode? {
    return self.baseWrapperNode
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
}
