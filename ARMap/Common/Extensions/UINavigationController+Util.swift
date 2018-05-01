//
//  UINavigationController+Util.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/11/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

extension UINavigationController {
  
  public func pushViewController(_ viewController: UIViewController, animated: Bool, animations: (() -> Void)?, completion: @escaping (_ completed: Bool) -> Void) {
    self.pushViewController(viewController, animated: animated)
    
    guard animated, let coordinator = self.transitionCoordinator else {
      completion(true)
      return
    }
    
    coordinator.animate(alongsideTransition: { context in
      animations?()
    }) { context in
      completion(!context.isCancelled)
    }
  }
  
  public func popViewController(animated: Bool, animations: (() -> Void)?, completion: @escaping (_ completed: Bool) -> Void) {
    self.popViewController(animated: animated)
    
    guard animated, let coordinator = self.transitionCoordinator else {
      completion(true)
      return
    }
    
    coordinator.animate(alongsideTransition: { context in
      animations?()
    }) { context in
      completion(!context.isCancelled)
    }
  }
  
  public func popToViewController(_ viewController: UIViewController, animated: Bool, animations: (() -> Void)?, completion: @escaping (_ completed: Bool) -> Void) {
    self.popToViewController(viewController, animated: animated)
    
    guard animated, let coordinator = self.transitionCoordinator else {
      completion(true)
      return
    }
    
    coordinator.animate(alongsideTransition: { context in
      animations?()
    }) { context in
      completion(!context.isCancelled)
    }
  }
  
  public func popToRootViewController(animated: Bool, animations: (() -> Void)?, completion: @escaping (_ completed: Bool) -> Void) {
    self.popToRootViewController(animated: animated)
    
    guard animated, let coordinator = self.transitionCoordinator else {
      completion(true)
      return
    }
    
    coordinator.animate(alongsideTransition: { context in
      animations?()
    }) { context in
      completion(!context.isCancelled)
    }
  }
}
