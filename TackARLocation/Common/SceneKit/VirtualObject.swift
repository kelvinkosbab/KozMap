//
//  VirtualObject.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/31/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import SceneKit

class VirtualObject : SCNNode {
  
  // MARK: - Properties
  
  let modelName: String
  let fileExtension: String
  var modelLoaded: Bool = false
  internal weak var baseWrapperNode: SCNNode? = nil
  
  // MARK: - Init
  
  init(modelName: String, fileExtension: String) {
    self.modelName = modelName
    self.fileExtension = fileExtension
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func loadModel(completion: @escaping () -> Void) {
    DispatchQueue.global().async { [weak self] in
      
      guard let strongSelf = self else {
        return
      }
      
      guard let virtualObjectScene = SCNScene(named: "\(strongSelf.modelName).\(strongSelf.fileExtension)", inDirectory: "Models.scnassets/") else {
        DispatchQueue.main.async {
          completion()
        }
        return
      }
      
      let wrapperNode = SCNNode()
      strongSelf.baseWrapperNode = wrapperNode
      
      for child in virtualObjectScene.rootNode.childNodes {
        wrapperNode.addChildNode(child)
      }
      
      DispatchQueue.main.async { [weak self] in
        self?.addChildNode(wrapperNode)
        self?.modelLoaded = true
        completion()
      }
    }
  }
  
  func unloadModel() {
    for child in self.childNodes {
      child.removeFromParentNode()
    }
    
    self.modelLoaded = false
  }
}

// MARK: - Protocols for Virtual Objects -

// MARK: - ReactsToScale

protocol ReactsToScale {
  func reactToScale()
}

extension SCNNode {
  
  var reactsToScale: ReactsToScale? {
    if let canReact = self as? ReactsToScale {
      return canReact
    }
    
    if let parent = self.parent {
      return parent.reactsToScale
    }
    
    return nil
  }
}
