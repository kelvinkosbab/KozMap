//
//  Double+Util.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation

extension Double {
  
  var oneDecimal: Double {
    return Double(Int(self*10))/10
  }
  
  var twoDecimal: Double {
    return Double(Int(self*100))/100
  }
  
  var threeDecimal: Double {
    return Double(Int(self*1000))/1000
  }
  
  var fourDecimal: Double {
    return Double(Int(self*10000))/10000
  }
}
