//
//  TopKnobVisualEffectPresentationManager.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 2/17/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class TopKnobVisualEffectPresentationManager : NSObject, UIViewControllerTransitioningDelegate, PresenationManagerProtocol {
  
  var interactiveElement: InteractiveElement?
  
  // MARK: - PresenationManagerProtocol
  
  var presentationInteractor: InteractiveTransition? = nil
  var dismissInteractor: InteractiveTransition? = nil
  weak var presentingViewControllerDelegate: PresentingViewControllerDelegate?
  
  required override init() {
    super.init()
  }
  
  required init(presentationInteractor: InteractiveTransition, dismissInteractor: InteractiveTransition) {
    self.presentationInteractor = presentationInteractor
    self.dismissInteractor = dismissInteractor
    super.init()
  }
  
  required init(presentationInteractor: InteractiveTransition) {
    self.presentationInteractor = presentationInteractor
    super.init()
  }
  
  required init(dismissInteractor: InteractiveTransition) {
    self.dismissInteractor = dismissInteractor
    super.init()
  }
  
  convenience init(interactiveElement: InteractiveElement?, dismissInteractor: InteractiveTransition) {
    self.init(dismissInteractor: dismissInteractor)
    self.interactiveElement = interactiveElement
  }
  
  // MARK: - UIViewControllerTransitioningDelegate
  
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    let controller = TopKnobVisualEffectPresentationController(presentedViewController: presented, presenting: source)
    controller.interactiveElement = self.interactiveElement
    return controller
  }
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return TopKnobVisualEffectAnimator(interactiveElement: self.interactiveElement, presentingViewControllerDelegate: self.presentingViewControllerDelegate)
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return TopKnobVisualEffectAnimator(interactiveElement: self.interactiveElement, presentingViewControllerDelegate: self.presentingViewControllerDelegate)
  }
  
  func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    if let presentationInteractor = self.presentationInteractor {
      return presentationInteractor.hasStarted ? presentationInteractor : nil
    }
    return nil
  }
  
  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    if let dismissInteractor = self.dismissInteractor {
      return dismissInteractor.hasStarted ? dismissInteractor : nil
    }
    return nil
  }
  
  // MARK: - Animator
  
  class TopKnobVisualEffectAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    let interactiveElement: InteractiveElement?
    weak var presentingViewControllerDelegate: PresentingViewControllerDelegate?
    
    init(interactiveElement: InteractiveElement?, presentingViewControllerDelegate: PresentingViewControllerDelegate?) {
      self.interactiveElement = interactiveElement
      self.presentingViewControllerDelegate = presentingViewControllerDelegate
      super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
      
      guard let toViewController = transitionContext.viewController(forKey: .to), let fromViewController = transitionContext.viewController(forKey: .from) else {
        return
      }
      
      let isUnwinding = toViewController.presentedViewController == fromViewController
      let isPresenting = !isUnwinding
      
      let presentingViewController = isPresenting ? fromViewController : toViewController
      let presentedViewController = isPresenting ? toViewController : fromViewController
      let containerView = transitionContext.containerView
      
      let presentedYOffset: CGFloat
      if let interactiveElement = self.interactiveElement {
        let knobViewRequiredOffset = TopKnobVisualEffectView.topKnobSpace + TopKnobVisualEffectView.knobHeight + TopKnobVisualEffectView.bottomKnobSpace
        presentedYOffset = (interactiveElement.size ?? 0) + knobViewRequiredOffset + (interactiveElement.offset ?? 0)
      } else {
        presentedYOffset = containerView.bounds.height
      }
      
      if isPresenting {
        
        // Currently presenting
        self.presentingViewControllerDelegate?.willPresentViewController(presentedViewController)
        presentedViewController.view.frame.origin.y = containerView.bounds.height
        containerView.addSubview(presentedViewController.view)
        
        // Animate the presentation
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
          presentingViewController.setNeedsStatusBarAppearanceUpdate()
          presentedViewController.setNeedsStatusBarAppearanceUpdate()
          presentedViewController.view.frame.origin.y -= presentedYOffset
          self.presentingViewControllerDelegate?.isPresentingViewController(presentedViewController)
        }, completion: { (_) in
          self.presentingViewControllerDelegate?.didPresentViewController(presentedViewController)
          transitionContext.completeTransition(true)
        })
        
      } else {
        
        // Currently dismissing
        self.presentingViewControllerDelegate?.willDismissViewController(presentedViewController)
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
          presentingViewController.setNeedsStatusBarAppearanceUpdate()
          presentedViewController.setNeedsStatusBarAppearanceUpdate()
          presentedViewController.view.frame.origin.y += presentedYOffset
          self.presentingViewControllerDelegate?.isDismissingViewController(presentedViewController)
        }, completion: { (_) in
          if !transitionContext.transitionWasCancelled {
            self.presentingViewControllerDelegate?.didDismissViewController(presentedViewController)
          }
          transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
      }
    }
  }
  
  // MARK: - Presentation Controller
  
  class TopKnobVisualEffectPresentationController : UIPresentationController {
    
    var interactiveElement: InteractiveElement?
    
    // MARK: - Properties
    
    private var dismissView: UIView? = nil
    private var topKnobVisualEffectView: TopKnobVisualEffectView? = nil
    
    override var shouldPresentInFullscreen: Bool {
      return false
    }
    
    // MARK: - Blur View
    
    private func createDismissView() -> UIView {
      let view = UIView()
      view.backgroundColor = .clear
      view.frame = self.presentingViewController.view.bounds
      view.isUserInteractionEnabled = true
      view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissController)))
      return view
    }
    
    // MARK: - UIPresentationController
    
    override func presentationTransitionWillBegin() {
      
      guard let containerView = self.containerView else {
        return
      }
      
      // Setup blur view
      let dismissView = self.dismissView ?? self.createDismissView()
      self.dismissView = dismissView
      dismissView.addToContainer(containerView, atIndex: 0)
    }
    
    override func containerViewWillLayoutSubviews() {
      super.containerViewWillLayoutSubviews()
      
      // Presented view
      let frameOfPresentedViewInContainerView = self.frameOfPresentedViewInContainerView
      self.presentedView?.frame = frameOfPresentedViewInContainerView
      
      // Configure the top knob view
      if self.topKnobVisualEffectView == nil, let presentedView = self.presentedView {
        
        // Crate the knob view
        let topKnobVisualEffectView = TopKnobVisualEffectView.newView()
        let knobViewRequiredOffset = TopKnobVisualEffectView.topKnobSpace + TopKnobVisualEffectView.knobHeight + TopKnobVisualEffectView.bottomKnobSpace
        topKnobVisualEffectView.addToContainer(presentedView, atIndex: 0, topMargin: -knobViewRequiredOffset)
      }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
      
      guard let size = self.containerView?.bounds.size else {
        return CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
      }
      
      let height: CGFloat
      if let size = self.interactiveElement?.size {
        let knobViewRequiredOffset = TopKnobVisualEffectView.topKnobSpace + TopKnobVisualEffectView.knobHeight + TopKnobVisualEffectView.bottomKnobSpace
        height = size + knobViewRequiredOffset
      } else {
        height = size.height
      }
      let yOffset: CGFloat = self.interactiveElement?.offset ?? 0
      return CGRect(x: 0, y: size.height - yOffset - height, width: size.width, height: height)
    }
    
    // MARK: - Actions
    
    @objc func dismissController() {
      self.presentedViewController.dismiss(animated: true, completion: nil)
    }
  }
}
