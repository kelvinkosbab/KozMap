//
//  InteractiveTransition.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

enum InteractiveTransitionMode {
  case percent, velocity
}

class InteractiveTransition : UIPercentDrivenInteractiveTransition {
  
  // MARK: - Static Constants
  
  static let defaultPercentThreshold: CGFloat = 0.3
  static let defaultVelocityThreshold: CGFloat = 850
  
  // MARK: - Properties / Init
  
  enum InteractorAxis {
    case x, y, xy
  }
  
  enum InteractorDirection {
    case negative, positive
  }
  
  weak var presentingController: UIViewController?
  var interactiveView: UIView?
  var activeGestureRecognizer: UIGestureRecognizer?
  
  let modes: [InteractiveTransitionMode]
  let percentThreshold: CGFloat
  let velocityThreshold: CGFloat
  
  var hasStarted: Bool = false
  var shouldFinish: Bool = false
  
  var lastTranslation: CGPoint? = nil
  var lastTranslationDate: Date? = nil
  var lastVelocity: CGFloat? = nil
  
  var axis: InteractiveTransition.InteractorAxis {
    return .xy
  }
  
  var direction: InteractiveTransition.InteractorDirection {
    return .positive
  }
  
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
  
  // MARK: - Dismiss
  
  final func dismissController(completion: (() -> Void)? = nil) {
    self.presentingController?.dismiss(animated: true, completion: completion)
  }
  
  // MARK: - Gestures
  
  @objc func handleGesture(_ sender: UIPanGestureRecognizer) {
    
    guard let view = self.interactiveView else {
      return
    }
    
    // Convert position to progress
    let translation = sender.translation(in: view)
    let progress = self.calculateProgress(translation: translation, in: view)
    //    sender.location(in: view)
    
    // Velocity calculations
    self.updateVelocityProperties(currentTranslation: translation)
    
    // Handle the gesture state
    self.handleGestureState(gesture: sender, progress: progress)
  }
  
  final func handleGestureState(gesture: UIPanGestureRecognizer, progress: CGFloat) {
    switch gesture.state {
    case .began:
      self.hasStarted = true
      self.dismissController()
      break
      
    case .changed:
      self.update(progress)
      self.shouldFinish = self.calculateShouldFinish(progress: progress, velocity: self.lastVelocity)
      break
      
    case .cancelled:
      self.hasStarted = false
      self.cancel()
      break
      
    case .ended:
      self.hasStarted = false
      self.shouldFinish ? self.finish() : self.cancel()
      break
      
    default:
      break
    }
  }
  
  // MARK: - Overrides
  
  override func finish() {
    self.lastTranslation = nil
    self.lastTranslationDate = nil
    self.lastVelocity = nil
    super.finish()
  }
  
  override func cancel() {
    self.lastTranslation = nil
    self.lastTranslationDate = nil
    self.lastVelocity = nil
    super.cancel()
  }
  
  // MARK: - Calculations
  
  final func updateVelocityProperties(currentTranslation: CGPoint) {
    let currentDate: Date = Date()
    if self.lastTranslation == nil && self.lastTranslationDate == nil {
      self.lastVelocity = nil
      self.lastTranslation = currentTranslation
      self.lastTranslationDate = currentDate
      
    } else if let lastTranslation = self.lastTranslation, let lastTranslationDate = self.lastTranslationDate, let velocity = self.calculateVelocity(lastTranslation: lastTranslation, lastTranslationDate: lastTranslationDate, currentTranslation: currentTranslation, currentTranslationDate: currentDate), (self.direction == .negative && velocity < 0) || (self.direction == .positive && velocity > 0) {
      self.lastVelocity = velocity
      self.lastTranslation = currentTranslation
      self.lastTranslationDate = currentDate
    }
  }
  
  final func calculateShouldFinish(progress: CGFloat, velocity: CGFloat?) -> Bool {
    if self.modes.contains(.percent) && progress > self.percentThreshold {
      return true
    } else if self.modes.contains(.velocity), let velocity = velocity, abs(velocity) > self.velocityThreshold {
      return true
    } else {
      return false
    }
  }
  
  final func calculateProgress(translation: CGPoint, in view: UIView) -> CGFloat {
    let xMovement = (self.direction == .negative ? -translation.x : translation.x) / view.bounds.width
    let yMovement = (self.direction == .negative ? -translation.y : translation.y) / view.bounds.height
    
    let movement: CGFloat
    switch self.axis {
    case .x:
      movement = xMovement
      break
    case .y:
      movement = yMovement
      break
    case .xy:
      movement = CGFloat(sqrt(pow(Double(xMovement), 2) + pow(Double(yMovement), 2)))
      break
    }
    return CGFloat(min(max(Double(movement), 0.0), 1.0))
  }
  
  final func calculateVelocity(lastTranslation: CGPoint, lastTranslationDate: Date, currentTranslation: CGPoint, currentTranslationDate: Date) -> CGFloat? {
    
    let duration = currentTranslationDate.timeIntervalSince(lastTranslationDate)
    guard duration != 0 else {
      return nil
    }
    
    let xVelocity: Double = Double(currentTranslation.x - lastTranslation.x) / duration
    let yVelocity: Double = Double(currentTranslation.y - lastTranslation.y) / duration
    
    switch self.axis {
    case .x:
      return CGFloat(xVelocity)
      
    case .y:
      return CGFloat(yVelocity)
      
    case .xy:
      return sqrt(CGFloat(pow(xVelocity, 2) + pow(yVelocity, 2)))
    }
  }
}
