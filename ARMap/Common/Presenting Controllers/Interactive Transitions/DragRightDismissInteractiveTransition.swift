//
//  DragRightDismissInteractiveTransition.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

class DragRightDismissInteractiveTransition : InteractiveTransition {
  
  override var axis: InteractiveTransition.InteractorAxis {
    return .x
  }
  
  override var direction: InteractiveTransition.InteractorDirection {
    return .positive
  }
}
