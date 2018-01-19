//
//  AxesNode.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/31/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import SceneKit

class AxesNode : SCNNode {
  
  // MARK: - Properties
  
  private let quiverNode: SCNNode
  
  // MARK: - Init
  
  init(quiverLength: CGFloat = 0.1, quiverThickness: CGFloat = 0.5) {
    
    // Thickness and radius
    let quiverThickness = (quiverLength / 50.0) * quiverThickness
    let chamferRadius = quiverThickness / 2.0
    
    // X
    let xQuiverBox = SCNBox(width: quiverLength, height: quiverThickness, length: quiverThickness, chamferRadius: chamferRadius)
    xQuiverBox.firstMaterial?.diffuse.contents = UIColor.red
    let xQuiverNode = SCNNode(geometry: xQuiverBox)
    xQuiverNode.position = SCNVector3Make(Float(quiverLength / 2.0), 0.0, 0.0)
    
    let xTextGeometry = SCNText(string: "X", extrusionDepth: 0.2)
    xTextGeometry.firstMaterial?.diffuse.contents = UIColor.red
    xTextGeometry.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    let xTextNode = SCNNode()
    xTextNode.geometry = xTextGeometry
    xTextNode.scale = SCNVector3(x:  0.001, y:  0.001, z: 0.001)
    xQuiverNode.addChildNode(xTextNode)
    
    // Y
    let yQuiverBox = SCNBox(width: quiverThickness, height: quiverLength, length: quiverThickness, chamferRadius: chamferRadius)
    yQuiverBox.firstMaterial?.diffuse.contents = UIColor.green
    let yQuiverNode = SCNNode(geometry: yQuiverBox)
    yQuiverNode.position = SCNVector3Make(0.0, Float(quiverLength / 2.0), 0.0)
    
    let yTextGeometry = SCNText(string: "Y", extrusionDepth: 0.2)
    yTextGeometry.firstMaterial?.diffuse.contents = UIColor.green
    yTextGeometry.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    let yTextNode = SCNNode()
    yTextNode.geometry = yTextGeometry
    yTextNode.scale = SCNVector3(x:  0.001, y:  0.001, z: 0.001)
    yQuiverNode.addChildNode(yTextNode)
    
    // Z
    let zQuiverBox = SCNBox(width: quiverThickness, height: quiverThickness, length: quiverLength, chamferRadius: chamferRadius)
    zQuiverBox.firstMaterial?.diffuse.contents = UIColor.blue
    let zQuiverNode = SCNNode(geometry: zQuiverBox)
    zQuiverNode.position = SCNVector3Make(0.0, 0.0, Float(quiverLength / 2.0))
    
    let zTextGeometry = SCNText(string: "Z", extrusionDepth: 0.2)
    zTextGeometry.firstMaterial?.diffuse.contents = UIColor.blue
    zTextGeometry.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    let zTextNode = SCNNode()
    zTextNode.geometry = zTextGeometry
    zTextNode.scale = SCNVector3(x:  0.001, y:  0.001, z: 0.001)
    zQuiverNode.addChildNode(zTextNode)
    
    // Quiver
    let quiverNode = SCNNode()
    quiverNode.addChildNode(xQuiverNode)
    quiverNode.addChildNode(yQuiverNode)
    quiverNode.addChildNode(zQuiverNode)
    quiverNode.name = "Axes"
    self.quiverNode = quiverNode
    
    super.init()
    
    self.addChildNode(quiverNode)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
