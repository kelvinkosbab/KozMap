//
//  AxesNode.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/31/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import SceneKit

class AxesNode : SCNNode {
  
  // MARK: - Properties
  
  private let quiverNode: SCNNode
  
  // MARK: - Init
  
  init(quiverLength: CGFloat = 0.1, quiverThickness: CGFloat = 0.5) {
    let quiverThickness = (quiverLength / 50.0) * quiverThickness
    let chamferRadius = quiverThickness / 2.0
    
    let xQuiverBox = SCNBox(width: quiverLength, height: quiverThickness, length: quiverThickness, chamferRadius: chamferRadius)
    xQuiverBox.firstMaterial?.diffuse.contents = UIColor.red
    let xQuiverNode = SCNNode(geometry: xQuiverBox)
    xQuiverNode.position = SCNVector3Make(Float(quiverLength / 2.0), 0.0, 0.0)
    
    let yQuiverBox = SCNBox(width: quiverThickness, height: quiverLength, length: quiverThickness, chamferRadius: chamferRadius)
    yQuiverBox.firstMaterial?.diffuse.contents = UIColor.green
    let yQuiverNode = SCNNode(geometry: yQuiverBox)
    yQuiverNode.position = SCNVector3Make(0.0, Float(quiverLength / 2.0), 0.0)
    
    let zQuiverBox = SCNBox(width: quiverThickness, height: quiverThickness, length: quiverLength, chamferRadius: chamferRadius)
    zQuiverBox.firstMaterial?.diffuse.contents = UIColor.blue
    let zQuiverNode = SCNNode(geometry: zQuiverBox)
    zQuiverNode.position = SCNVector3Make(0.0, 0.0, Float(quiverLength / 2.0))
    
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
