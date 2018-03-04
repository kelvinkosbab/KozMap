//
//  ClassNamable.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/3/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import Foundation

protocol ClassNamable {}
extension ClassNamable {
  
  static var name: String {
    return String(describing: Self.self)
  }
  
  var className: String {
    return String(describing: type(of: self))
  }
}
