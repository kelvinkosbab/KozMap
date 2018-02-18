//
//  PresentingViewControllerDelegate.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 2/17/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

protocol PresentingViewControllerDelegate : class {
  func willPresentViewController(_ viewController: UIViewController)
  func isPresentingViewController(_ viewController: UIViewController?)
  func didPresentViewController(_ viewController: UIViewController?)
  func willDismissViewController(_ viewController: UIViewController)
  func isDismissingViewController(_ viewController: UIViewController?)
}
