//
//  VisualEffectFadePresentationManager.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 2/17/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class VisualEffectFadePresentationManager : NSObject, UIViewControllerTransitioningDelegate, PresenationManagerProtocol {
  
  // MARK: - MyPresenationManager
  
  var presentationInteractor: InteractiveTransition? = nil
  var dismissInteractor: InteractiveTransition? = nil
  
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
  
  // MARK: - UIViewControllerTransitioningDelegate
  
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    return VisualEffectFadePresentationController(presentedViewController: presented, presenting: source)
  }
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return VisualEffectFadeAnimator()
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return VisualEffectFadeAnimator()
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
  
  class VisualEffectFadeAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
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
      
      if isPresenting {
        
        // Currently presenting
        
        if let presentingDelegate = presentingViewController as? PresentingViewControllerDelegate {
          presentingDelegate.willPresentViewController(presentedViewController)
        }
        
        presentedViewController.view.alpha = 0
        containerView.addSubview(presentedViewController.view)
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
          presentedViewController.view.alpha = 1
          presentingViewController.setNeedsStatusBarAppearanceUpdate()
          presentedViewController.setNeedsStatusBarAppearanceUpdate()
          
          if let presentingDelegate = presentingViewController as? PresentingViewControllerDelegate {
            presentingDelegate.isPresentingViewController(presentedViewController)
          }
          
        }, completion: { _ in
          
          if let presentingDelegate = presentingViewController as? PresentingViewControllerDelegate {
            presentingDelegate.didPresentViewController(presentedViewController)
          }
          
          // Completion
          transitionContext.completeTransition(true)
        })
        
      } else {
        
        // Currently not presenting
        
        if let presentingDelegate = presentingViewController as? PresentingViewControllerDelegate {
          presentingDelegate.willDismissViewController(presentedViewController)
        }
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
          presentedViewController.view.alpha = 0
          presentingViewController.setNeedsStatusBarAppearanceUpdate()
          presentedViewController.setNeedsStatusBarAppearanceUpdate()
          
          if let presentingDelegate = presentingViewController as? PresentingViewControllerDelegate {
            presentingDelegate.isDismissingViewController(presentedViewController)
          }
          
        }, completion: { _ in
          transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
      }
    }
  }
  
  // MARK: - Presentation Controller
  
  class VisualEffectFadePresentationController : UIPresentationController {
    
    // MARK: - Properties
    
    private var blurView: UIVisualEffectView? = nil
    
    override var shouldPresentInFullscreen: Bool {
      return true
    }
    
    // MARK: - Blur View
    
    private func createBlurView() -> UIVisualEffectView {
      let blurView = UIVisualEffectView(effect: nil)
      blurView.frame = self.presentingViewController.view.bounds
      return blurView
    }
    
    // MARK: - UIPresentationController
    
    override func presentationTransitionWillBegin() {
      
      guard let containerView = self.containerView else {
        return
      }
      
      // Setup blur view
      let blurView = self.blurView ?? self.createBlurView()
      self.blurView = blurView
      blurView.addToContainer(containerView, atIndex: 0)
      blurView.effect = nil
      
      // Begin animation
      self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
        blurView.effect = UIBlurEffect(style: .dark)
      }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
      self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
        self.blurView?.effect = nil
      }, completion: nil)
    }
    
    override func containerViewWillLayoutSubviews() {
      super.containerViewWillLayoutSubviews()
      
      self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
      return self.containerView?.frame ?? UIScreen.main.bounds
    }
    
    // MARK: - Actions
    
    @objc func dismissController() {
      self.presentedViewController.dismiss(animated: true, completion: nil)
    }
  }
}
