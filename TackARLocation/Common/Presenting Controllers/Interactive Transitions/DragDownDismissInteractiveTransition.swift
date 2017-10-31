//
//  DragDownDismissInteractiveTransition.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit

class DragDownDismissInteractiveTransition : InteractiveTransition {
  
  override var axis: InteractiveTransition.InteractorAxis {
    return .y
  }
  
  override var direction: InteractiveTransition.InteractorDirection {
    return .positive
  }
}
