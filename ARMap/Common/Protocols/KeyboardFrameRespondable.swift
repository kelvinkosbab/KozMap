//
//  KeyboardFrameRespondable.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 1/3/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import UIKit

protocol KeyboardFrameRespondable : class {
  var view: UIView! { get }
  var preferredContentSize: CGSize { get }
}

extension KeyboardFrameRespondable {
  
//  NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification(_:)), name: .UIKeyboardWillShow, object: nil)
//  NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification(_:)), name: .UIKeyboardWillHide, object: nil)
  
//  @objc func handleKeyboardNotification(_ notification: NSNotification) {
//
//    guard let presentedViewController = self.presentedViewController as? KeyboardFrameRespondable ?? (self.presentedViewController as? UINavigationController)?.viewControllers.first as? KeyboardFrameRespondable, let userInfo = notification.userInfo else {
//      return
//    }
//
//    // Keyboard presentation properties
//    let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
//    let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
//    let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
//    let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
//    let animationCurve = UIViewAnimationOptions(rawValue: animationCurveRaw)
//    let keyboardOffset: CGFloat
//    if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
//      keyboardOffset = 0
//    } else {
//      let safeAreaOffset = self.view.safeAreaLayoutGuide.layoutFrame.origin.y / 4
//      keyboardOffset = (endFrame?.size.height ?? 0.0) - safeAreaOffset
//    }
//
//    // Calculate the new frame
//    let xOffset = presentedViewController.view.frame.origin.x
//    let presentedViewControllerHeight = presentedViewController.view.bounds.height
//    let yOffset = self.view.bounds.height - keyboardOffset - presentedViewControllerHeight
//    let newFrame = CGRect(x: xOffset, y: max(yOffset, 100), width: presentedViewController.view.bounds.width, height: presentedViewControllerHeight)
//
//    // Perform the animation
//    UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: { [weak self] in
//      self?.presentedViewController?.view.frame = newFrame
//    })
//  }
}
