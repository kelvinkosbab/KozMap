//
//  InteractiveTransition+Subclasses.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 2/19/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import UIKit

// MARK: - DragUpDismissInteractiveTransition

class DragUpDismissInteractiveTransition : InteractiveTransition {
  
  init?(interactiveViews: [UIView], scrollViewInteractiveSenderDelegate: ScrollViewInteractiveSenderDelegate?, options: [InteractiveTransition.Option] = [], delegate: InteractiveTransitionDelegate? = nil) {
    super.init(interactiveViews: interactiveViews, scrollViewInteractiveSenderDelegate: scrollViewInteractiveSenderDelegate, axis: .y, direction: .negative, options: options, delegate: delegate)
  }
}

// MARK: - DragDownDismissInteractiveTransition

class DragDownDismissInteractiveTransition : InteractiveTransition {
  
  init?(interactiveViews: [UIView], scrollViewInteractiveSenderDelegate: ScrollViewInteractiveSenderDelegate?, options: [InteractiveTransition.Option] = [], delegate: InteractiveTransitionDelegate? = nil) {
    super.init(interactiveViews: interactiveViews, scrollViewInteractiveSenderDelegate: scrollViewInteractiveSenderDelegate, axis: .y, direction: .positive, options: options, delegate: delegate)
  }
}

// MARK: - DragLeftDismissInteractiveTransition

class DragLeftDismissInteractiveTransition : InteractiveTransition {
  
  init?(interactiveViews: [UIView], scrollViewInteractiveSenderDelegate: ScrollViewInteractiveSenderDelegate?, options: [InteractiveTransition.Option] = [], delegate: InteractiveTransitionDelegate? = nil) {
    super.init(interactiveViews: interactiveViews, scrollViewInteractiveSenderDelegate: scrollViewInteractiveSenderDelegate, axis: .x, direction: .negative, options: options, delegate: delegate)
  }
}

// MARK: - DragRightDismissInteractiveTransition

class DragRightDismissInteractiveTransition : InteractiveTransition {
  
  init?(interactiveViews: [UIView], scrollViewInteractiveSenderDelegate: ScrollViewInteractiveSenderDelegate?, options: [InteractiveTransition.Option] = [], delegate: InteractiveTransitionDelegate? = nil) {
    super.init(interactiveViews: interactiveViews, scrollViewInteractiveSenderDelegate: scrollViewInteractiveSenderDelegate, axis: .x, direction: .positive, options: options, delegate: delegate)
  }
}
