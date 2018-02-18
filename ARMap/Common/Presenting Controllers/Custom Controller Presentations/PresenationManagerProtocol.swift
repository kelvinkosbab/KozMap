//
//  PresenationManagerProtocol.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

protocol PresenationManagerProtocol : class {
  var presentationInteractor: InteractiveTransition? { get set }
  var dismissInteractor: InteractiveTransition? { get set }
  var presentingViewControllerDelegate: PresentingViewControllerDelegate? { get set }
  init(presentationInteractor: InteractiveTransition, dismissInteractor: InteractiveTransition)
  init(presentationInteractor: InteractiveTransition)
  init(dismissInteractor: InteractiveTransition)
  init()
}
