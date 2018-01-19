//
//  Plane.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import SceneKit

class Plane : SCNNode {
  
  let planeGeometry: SCNBox
  
  init(width: CGFloat, length: CGFloat) {
    
    // Using a SCNBox and not SCNPlane to make it easy for the geometry we add to the scene to interact with the plane.
    // For the physics engine to work properly give the plane some height so we get interactions between the plane and the gometry we add to the scene
    let planeHeight: CGFloat = 0.05
    self.planeGeometry = SCNBox(width: width, height: planeHeight, length: length, chamferRadius: 0)
    super.init()
    
    // Since we are using a cube, we only want to render the tron grid on the top face, make the other sides transparent
    let transparentMaterial = SCNMaterial.transparent
    self.planeGeometry.materials = [ transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial ]
    
    // Since our plane has some height, move it down to be at the actual surface
    let planeNode = SCNNode(geometry: self.planeGeometry)
    planeNode.position = SCNVector3(x: 0, y: -Float(planeHeight) / 2, z: 0)
    
    // Give the plane a physics body so that items we add to the scene interact with it
    planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
    
    self.setTextureScale()
    self.addChildNode(planeNode)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setTextureScale() {
    let width = self.planeGeometry.width
    let height = self.planeGeometry.height
    
    // As the width/height of the plane updates, we want our tron grid material to cover the entire plane, repeating the texture over and over. Also if the grid is less than 1 unit, we don't want to squash the texture to fit, so scaling updates the texture co-ordinates to crop the texture in that case
    let material = self.planeGeometry.materials.first
    material?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), Float(height), 1)
    material?.diffuse.wrapS = .repeat
    material?.diffuse.wrapT = .repeat
  }
}
