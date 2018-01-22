//
//  DragDownDismissInteractiveTransition.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

class DragDownDismissInteractiveTransition : DragInteractiveTransition {
  
  override var axis: DragInteractiveTransition.InteractorAxis {
    return .y
  }
  
  override var direction: DragInteractiveTransition.InteractorDirection {
    return .positive
  }
}
