//
//  KeyboardFrameRespondable.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 1/3/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

protocol KeyboardFrameRespondable : class {
  var view: UIView! { get }
  var preferredContentSize: CGSize { get }
}
