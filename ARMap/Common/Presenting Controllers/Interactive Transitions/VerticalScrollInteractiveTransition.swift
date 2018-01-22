//
//  VerticalScrollInteractiveTransition.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 1/22/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import UIKit

enum TransitionDirection {
  case forward, reverse
}

protocol VerticalScrollInteractionViewDelegate : class {
  var canScroll: Bool { get set }
  var safeScrollHeight: CGFloat { get set }
}

protocol VerticalScrollInteractionDelegate : VerticalScrollInteractionViewDelegate {
  var scrollTransitionDirection: TransitionDirection { get }
  var shouldRecognizePanSimultaneously: Bool { get }
  
  func getForwardViewController() -> UIViewController?
  func finishedInteractiveTransition()
  func disableInteractiveTransition()
}

extension VerticalScrollInteractionDelegate where Self : UIViewController {
  
  func disableInteractiveTransition() {
    // Calls verticalScrollInteractionController.isEnabled = false
  }
}

protocol VerticalScrollTransitionDirector : class {
  
  var verticalScrollDelegate: VerticalScrollInteractionDelegate? { get }
  
  func shouldPresent(viewController: UIViewController)
  func shouldDismissVerticalScrollController(animated: Bool)
  func transitionBegan()
  func transitionEnded()
}

class VerticalScrollInteractionController: UIPercentDrivenInteractiveTransition {
  
  var panGestureRecognizer: UIPanGestureRecognizer? = nil
  var fromDelegate: VerticalScrollInteractionDelegate? = nil
  var initialLocationY: CGFloat = 0
  var isEnabled: Bool = true
  
  var completionSeed: CGFloat {
    return 1 - self.percentComplete
  }
  
  weak var director: VerticalScrollTransitionDirector?
  
  init(director: VerticalScrollTransitionDirector) {
    self.director = director
    super.init()
    self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panHandler))
    self.panGestureRecognizer?.delegate = self
  }
  
  deinit {
    if let recognizer = self.panGestureRecognizer {
      recognizer.view?.removeGestureRecognizer(recognizer)
    }
  }
  
  func attachToView(_ view: UIView) {
    guard let recognizer = self.panGestureRecognizer else { return }
    recognizer.view?.removeGestureRecognizer(recognizer)
    view.addGestureRecognizer(recognizer)
  }
  
  @objc func panHandler(_ recognizer: UIPanGestureRecognizer) {
    
    guard let view = recognizer.view, let verticalScrollDelegate = self.director?.verticalScrollDelegate else {
      return
    }
    
    let location = recognizer.location(in: view)
    let velocity = recognizer.velocity(in: view)
    let direction = verticalScrollDelegate.scrollTransitionDirection
    
    switch(recognizer.state) {
    case .began:
      self.director?.transitionBegan()
      self.beginTransition(location, verticalScrollDelegate: verticalScrollDelegate, direction: direction)
    case .changed:
      self.changed(location: location, view: view, direction: direction, delegate: verticalScrollDelegate)
    case .ended:
      self.endTransition(velocity: velocity, delegate: verticalScrollDelegate)
      self.fromDelegate = nil
      self.director?.transitionEnded()
    default: break
    }
  }
  
  fileprivate func beginTransition(_ location: CGPoint, verticalScrollDelegate: VerticalScrollInteractionDelegate, direction: TransitionDirection) {
    guard verticalScrollDelegate.canScroll || (location.y < verticalScrollDelegate.safeScrollHeight) else {
      return
    }
    
    // For Use In Reverse Animation Offset
    self.initialLocationY = location.y
    
    // Save delegate for use when finishing transition
    self.fromDelegate = verticalScrollDelegate
    
    switch direction {
    case .forward:
      if let viewController = verticalScrollDelegate.getForwardViewController() {
        self.director?.shouldPresent(viewController: viewController)
      }
    case .reverse:
      self.director?.shouldDismissVerticalScrollController(animated: true)
    }
  }
  
  fileprivate func changed(location: CGPoint, view: UIView, direction: TransitionDirection, delegate: VerticalScrollInteractionDelegate) {
    if fromDelegate == nil {
      self.beginTransition(location, verticalScrollDelegate: delegate, direction: direction)
    } else {
      let animationRatio = self.calculateAnimationRatio(direction, initialY: self.initialLocationY, currentY: location.y, viewBounds: view.bounds)
      self.update(animationRatio)
    }
  }
  
  fileprivate func endTransition(velocity: CGPoint, delegate: VerticalScrollInteractionDelegate) {
    
    let shouldCancel: Bool
    if let fromDelegate = self.fromDelegate {
      shouldCancel = (self.initialLocationY < fromDelegate.safeScrollHeight) || fromDelegate.canScroll
    } else {
      shouldCancel = true
    }
    
    guard !shouldCancel else {
      self.cancel()
      return
    }
    
    // Delegate is now the pushed view controller
    switch delegate.scrollTransitionDirection {
    case .forward:
      if velocity.y > 200.0 {
        self.finish()
        delegate.finishedInteractiveTransition()
      } else {
        self.cancel()
      }
    case .reverse:
      if velocity.y < -200.0 {
        self.finish()
        delegate.finishedInteractiveTransition()
      } else {
        self.cancel()
      }
    }
  }
  
  fileprivate func calculateAnimationRatio(_ direction: TransitionDirection, initialY: CGFloat, currentY: CGFloat, viewBounds: CGRect ) -> CGFloat {
    switch direction {
    case .forward:
      return (currentY - initialY) / viewBounds.height
    case .reverse:
      return (initialY - currentY) / viewBounds.height
    }
  }
}

// MARK: - UIGestureRecognizerDelegate

extension VerticalScrollInteractionController : UIGestureRecognizerDelegate {
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    
    guard let verticalScrollDelegate = self.director?.verticalScrollDelegate else {
      return false
    }
    
    if otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
      return verticalScrollDelegate.shouldRecognizePanSimultaneously
    } else if otherGestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) {
      return false
    } else {
      return true
    }
  }
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    
    guard self.isEnabled, let verticalScrollDelegate = self.director?.verticalScrollDelegate, let view = gestureRecognizer.view, let velocity = self.panGestureRecognizer?.velocity(in: view) else {
      return false
    }
    
    let verticalMotion = abs(velocity.y) > abs(velocity.x)
    switch verticalScrollDelegate.scrollTransitionDirection {
    case .forward:
      return verticalMotion && velocity.y < 0
    case .reverse:
      return verticalMotion && velocity.y > 0
    }
  }
}
