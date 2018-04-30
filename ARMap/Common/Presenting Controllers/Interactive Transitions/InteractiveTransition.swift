//
//  InteractiveTransition.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 1/22/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import UIKit

// MARK: - PresentationInteractable

protocol PresentationInteractable : class {
  var presentationInteractiveViews: [UIView] { get }
}

// MARK: - DismissInteractable

protocol DismissInteractable : class {
  var dismissInteractiveViews: [UIView] { get }
}

// MARK: - ScrollViewInteractiveSenderDelegate

protocol ScrollViewInteractiveSenderDelegate : class {
  var scrollViewInteractiveReceiverDelegate: ScrollViewInteractiveReceiverDelegate? { get set }
}

// MARK: - ScrollViewInteractiveReceiverDelegate

protocol ScrollViewInteractiveReceiverDelegate : class {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
  func scrollViewDidScroll(_ scrollView: UIScrollView)
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
}

// MARK: - InteractiveTransitionDelegate

protocol InteractiveTransitionDelegate : class {
  func interactionDidSurpassThreshold(_ interactiveTransition: InteractiveTransition)
}

// MARK: - InteractiveTransition

class InteractiveTransition : UIPercentDrivenInteractiveTransition {
  
  // MARK: - Properties
  
  let interactiveViews: [UIView]
  let scrollViewInteractiveSenderDelegate: ScrollViewInteractiveSenderDelegate?
  let axis: InteractiveTransition.Axis
  let direction: InteractiveTransition.Direction
  weak var delegate: InteractiveTransitionDelegate? = nil
  
  let gestureType: InteractiveTransition.GestureType
  let contentSize: CGSize?
  let percentThreshold: CGFloat
  let velocityThreshold: CGFloat
  
  internal(set) var hasStarted: Bool = false
  internal(set) var shouldFinish: Bool = false
  private var activeGestureRecognizers: [UIPanGestureRecognizer] = []
  
  private var lastTranslation: CGPoint? = nil
  private var lastTranslationDate: Date? = nil
  private var lastVelocity: CGFloat? = nil
  internal var lastContentOffset: CGPoint? = nil
  
  // MARK: - Init
  
  init?(interactiveViews: [UIView], scrollViewInteractiveSenderDelegate: ScrollViewInteractiveSenderDelegate?, axis: InteractiveTransition.Axis, direction: InteractiveTransition.Direction, gestureType: GestureType = .pan, options: [InteractiveTransition.Option] = [], delegate: InteractiveTransitionDelegate? = nil) {
    
    guard interactiveViews.count > 0 else {
      return nil
    }
    
    self.interactiveViews = interactiveViews
    self.scrollViewInteractiveSenderDelegate = scrollViewInteractiveSenderDelegate
    self.axis = axis
    self.direction = direction
    self.delegate = delegate
    
    self.gestureType = options.gestureType
    self.contentSize = options.contentSize
    self.percentThreshold = options.percentThreshold
    self.velocityThreshold = options.velocityThreshold
    
    super.init()
    
    // Configure the gestures for the interactive views
    for interactiveView in interactiveViews {
      
      // Skip scroll views
      if let scrollView = interactiveView as? UIScrollView, scrollView.isScrollEnabled {
        continue
      }
      
      // Configure the gesture for the view
      let gestureRecognizer = self.gestureType.createGestureRecognizer(target: self, action: #selector(self.handleGesture(_:)), axis: self.axis, direction: self.direction)
      interactiveView.isUserInteractionEnabled = true
      interactiveView.addGestureRecognizer(gestureRecognizer)
      self.activeGestureRecognizers.append(gestureRecognizer)
    }
    
    // Configure the scroll view interactive delegate
    scrollViewInteractiveSenderDelegate?.scrollViewInteractiveReceiverDelegate = self
  }
  
  // MARK: - Gestures
  
  @objc private func handleGesture(_ sender: UIPanGestureRecognizer) {
    
    guard let view = sender.view, self.interactiveViews.contains(view) else {
      return
    }
    
    // Convert position to progress
    let translation = sender.translation(in: view)
    let progress = self.calculateProgress(translation: translation, inBounds: view.bounds)
    
    // Velocity calculations
    self.updateVelocityProperties(currentTranslation: translation)
    
    // Handle the gesture state
    self.handleGestureState(sender.state, progress: progress)
  }
  
  internal func handleGestureState(_ gestureState: UIGestureRecognizerState, progress: CGFloat) {
    switch gestureState {
    case .began:
      self.hasStarted = true
      self.delegate?.interactionDidSurpassThreshold(self)
      self.update(progress)
      self.shouldFinish = self.calculateShouldFinish(progress: progress, velocity: self.lastVelocity)
    case .changed:
      self.update(progress)
      self.shouldFinish = self.calculateShouldFinish(progress: progress, velocity: self.lastVelocity)
    case .cancelled:
      self.hasStarted = false
      self.cancel()
    case .ended:
      self.hasStarted = false
      self.shouldFinish ? self.finish() : self.cancel()
    default: break
    }
  }
  
  // MARK: - Overrides
  
  override func finish() {
    self.lastTranslation = nil
    self.lastTranslationDate = nil
    self.lastVelocity = nil
    self.lastContentOffset = nil
    super.finish()
  }
  
  override func cancel() {
    self.lastTranslation = nil
    self.lastTranslationDate = nil
    self.lastVelocity = nil
    self.lastContentOffset = nil
    super.cancel()
  }
  
  // MARK: - Calculations
  
  internal func updateVelocityProperties(currentTranslation: CGPoint) {
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
  
  internal func calculateShouldFinish(progress: CGFloat, velocity: CGFloat?) -> Bool {
    if progress > self.percentThreshold {
      return true
    } else if let velocity = velocity, abs(velocity) > self.velocityThreshold {
      return true
    }
    return false
  }
  
  private func calculateProgress(translation: CGPoint, inBounds viewBounds: CGRect) -> CGFloat {
    let xMovement = (self.direction == .negative ? -translation.x : translation.x) / (self.contentSize?.width ?? viewBounds.width)
    let yMovement = (self.direction == .negative ? -translation.y : translation.y) / (self.contentSize?.height ?? viewBounds.height)
    
    let movement: CGFloat
    switch self.axis {
    case .x:
      movement = xMovement
    case .y:
      movement = yMovement
    case .xy:
      movement = CGFloat(sqrt(pow(Double(xMovement), 2) + pow(Double(yMovement), 2)))
    }
    
    return CGFloat(min(max(Double(movement), 0.0), 1.0))
  }
  
  private func calculateVelocity(lastTranslation: CGPoint, lastTranslationDate: Date, currentTranslation: CGPoint, currentTranslationDate: Date) -> CGFloat? {
    
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

// MARK: - ScrollViewInteractiveReceiverDelegate

extension InteractiveTransition : ScrollViewInteractiveReceiverDelegate {
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    
    // Determine if should begin dismissal
    if self.axis == .y && self.direction == .positive && -scrollView.contentOffset.y >= scrollView.adjustedContentInset.top {
      self.lastContentOffset = scrollView.contentOffset
    } else if self.axis == .y && self.direction == .negative && -scrollView.contentOffset.y <= scrollView.contentSize.height {
      self.lastContentOffset = scrollView.contentOffset
    } else if self.axis == .x && self.direction == .positive && -scrollView.contentOffset.x >= scrollView.contentInset.left {
      self.lastContentOffset = scrollView.contentOffset
    } else if self.axis == .x && self.direction == .negative && -scrollView.contentOffset.x <= scrollView.contentSize.width {
      self.lastContentOffset = scrollView.contentOffset
    } else {
      self.lastContentOffset = nil
    }
    
    // Only update if the interactive gesture has started
    guard self.hasStarted else {
      return
    }
    
    // Handle the scrolling gesture
    self.handleScrollingGesture(scrollView, gestureState: .began)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    // Check if valid last content offset
    guard let lastContentOffset = self.lastContentOffset else {
      return
    }
    
    // Check if this scroll gesture has already started
    if self.hasStarted {
      
      // Handle the scrolling gesture
      self.handleScrollingGesture(scrollView, gestureState: .changed)
      return
    }
    
    // Check if the scroll dismiss should start
    if self.axis == .y && self.direction == .positive && scrollView.contentOffset.y <= lastContentOffset.y {
      self.hasStarted = true
      self.handleScrollingGesture(scrollView, gestureState: .began)
    } else if self.axis == .y && self.direction == .negative && scrollView.contentOffset.y >= lastContentOffset.y {
      self.hasStarted = true
      self.handleScrollingGesture(scrollView, gestureState: .began)
    } else if self.axis == .x && self.direction == .positive && scrollView.contentOffset.x <= lastContentOffset.x {
      self.hasStarted = true
      self.handleScrollingGesture(scrollView, gestureState: .began)
    } else if self.axis == .x && self.direction == .negative && scrollView.contentOffset.x >= lastContentOffset.x {
      self.hasStarted = true
      self.handleScrollingGesture(scrollView, gestureState: .began)
    } else {
      self.lastContentOffset = nil
    }
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    
    // Only update if the interactive gesture has started
    guard self.hasStarted else {
      return
    }
    
    // Handle the scrolling gesture
    self.handleScrollingGesture(scrollView, gestureState: .ended)
  }
  
  private func handleScrollingGesture(_ scrollView: UIScrollView, gestureState: UIGestureRecognizerState) {
    
    // Calculate translation
    let scrollTranslation: CGPoint?
    if self.axis == .y && self.direction == .positive {
      scrollTranslation = CGPoint(x: 0, y: -scrollView.contentOffset.y - scrollView.adjustedContentInset.top)
    } else if self.axis == .y && self.direction == .negative {
      scrollTranslation = CGPoint(x: 0, y: -scrollView.contentOffset.y - scrollView.contentSize.height)
    } else if self.axis == .x && self.direction == .positive {
      scrollTranslation = CGPoint(x: -scrollView.contentOffset.x - scrollView.contentInset.left, y: 0)
    } else if self.axis == .x && self.direction == .negative {
      scrollTranslation = CGPoint(x: -scrollView.contentOffset.x - scrollView.contentSize.width, y: 0)
    } else {
      scrollTranslation = nil
    }
    
    guard let translation = scrollTranslation else {
      return
    }
    
    // Convert position to progress
    let progress = self.calculateProgress(translation: translation, inBounds: scrollView.bounds)
    
    // Velocity calculations
    self.updateVelocityProperties(currentTranslation: translation)
    
    // Update the last content offset
    self.lastContentOffset = scrollView.contentOffset
    
    // Handle the gesture state
    self.handleGestureState(gestureState, progress: progress * 2)
  }
}
