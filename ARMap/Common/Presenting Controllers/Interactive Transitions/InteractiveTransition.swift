//
//  InteractiveTransition.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 1/22/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import UIKit

enum InteractiveTransitionMode {
  case percent, velocity
}

class InteractiveTransition : UIPercentDrivenInteractiveTransition {
  
  // MARK: - Static Constants
  
  static let defaultPercentThreshold: CGFloat = 0.3
  static let defaultVelocityThreshold: CGFloat = 850
  
  // MARK: - Properties
  
  var hasStarted: Bool = false
  var shouldFinish: Bool = false
  
  weak var presentingController: UIViewController?
  var interactiveView: UIView?
  var activeGestureRecognizer: UIGestureRecognizer?
  
  let modes: [InteractiveTransitionMode]
  let percentThreshold: CGFloat
  let velocityThreshold: CGFloat
  
  var lastTranslation: CGPoint? = nil
  var lastTranslationDate: Date? = nil
  var lastVelocity: CGFloat? = nil
  
  // MARK: - Init
  
  convenience init(presentingController: UIViewController, interactiveController: UIViewController?, modes: [InteractiveTransitionMode] = [ .percent, .velocity ]) {
    self.init(presentingController: presentingController, interactiveView: interactiveController?.view ?? nil, modes: modes)
  }
  
  init(presentingController: UIViewController, interactiveView: UIView?, modes: [InteractiveTransitionMode] = [ .percent, .velocity ], percentThreshold: CGFloat = InteractiveTransition.defaultPercentThreshold, velocityThreshold: CGFloat = InteractiveTransition.defaultVelocityThreshold) {
    self.presentingController = presentingController
    self.interactiveView = interactiveView
    self.modes = modes
    self.percentThreshold = percentThreshold
    self.velocityThreshold = velocityThreshold
    super.init()
    
    // Configure the view for interaction
    if let interactiveView = self.interactiveView {
      interactiveView.isUserInteractionEnabled = true
      let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleGesture(_:)))
      interactiveView.addGestureRecognizer(panGestureRecognizer)
      self.activeGestureRecognizer = panGestureRecognizer
    } else {
      self.activeGestureRecognizer = nil
    }
  }
  
  // MARK: - Gestures
  
  @objc func handleGesture(_ sender: UIPanGestureRecognizer) {
    Log.log("This method should be overriden by a subclass")
  }
}
