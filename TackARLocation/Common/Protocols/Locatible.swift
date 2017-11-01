//
//  Locatible.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 11/1/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import CoreLocation

protocol Locatible : class {
  var location: CLLocation? { get set }
}
