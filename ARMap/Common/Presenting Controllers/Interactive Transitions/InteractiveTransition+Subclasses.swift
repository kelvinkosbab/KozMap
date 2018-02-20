//
//  InteractiveTransition+Subclasses.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 2/19/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

// MARK: - DragUpDismissInteractiveTransition

class DragUpDismissInteractiveTransition : InteractiveTransition {
  
  init?(interactiveViews: [UIView], modes: [InteractiveTransitionMode] = [ .percent(nil), .velocity(nil) ], delegate: InteractiveTransitionDelegate? = nil) {
    super.init(interactiveViews: interactiveViews, axis: .y, direction: .negative, modes: modes, delegate: delegate)
  }
}

// MARK: - DragDownDismissInteractiveTransition

class DragDownDismissInteractiveTransition : InteractiveTransition {
  
  init?(interactiveViews: [UIView], modes: [InteractiveTransitionMode] = [ .percent(nil), .velocity(nil) ], delegate: InteractiveTransitionDelegate? = nil) {
    super.init(interactiveViews: interactiveViews, axis: .y, direction: .positive, modes: modes, delegate: delegate)
  }
}

// MARK: - DragLeftDismissInteractiveTransition

class DragLeftDismissInteractiveTransition : InteractiveTransition {
  
  init?(interactiveViews: [UIView], modes: [InteractiveTransitionMode] = [ .percent(nil), .velocity(nil) ], delegate: InteractiveTransitionDelegate? = nil) {
    super.init(interactiveViews: interactiveViews, axis: .x, direction: .negative, modes: modes, delegate: delegate)
  }
}

// MARK: - DragRightDismissInteractiveTransition

class DragRightDismissInteractiveTransition : InteractiveTransition {
  
  init?(interactiveViews: [UIView], modes: [InteractiveTransitionMode] = [ .percent(nil), .velocity(nil) ], delegate: InteractiveTransitionDelegate? = nil) {
    super.init(interactiveViews: interactiveViews, axis: .x, direction: .positive, modes: modes, delegate: delegate)
  }
}
