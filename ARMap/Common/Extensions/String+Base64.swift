//
//  String+Base64.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/3/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import Foundation

extension String {
  
  var base64Encoded: String? {
    return self.data(using: .utf8)?.base64EncodedString()
  }
  
  var base64Decoded: String? {
    if let data = Data(base64Encoded: self) {
      return String(data: data, encoding: .utf8)
    }
    return nil
  }
  
  var isBase64: Bool {
    if let base64Decoded = self.base64Decoded, !base64Decoded.isEmpty {
      return true
    }
    return false
  }
}
