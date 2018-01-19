//
//  String+Util.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/8/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import Foundation

extension String {
  
  // MARK: - Util
  
  var trimmed: String {
    return self.trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  var urlEncoded: String? {
    return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
  }
  
  var urlDecoded: String? {
    return self.removingPercentEncoding
  }
  
  func contains(string: String) -> Bool {
    return self.range(of: string) != nil
  }
  
  func containsIgnoreCase(string: String) -> Bool {
    return self.lowercased().range(of: string.lowercased()) != nil
  }
  
  var withoutWhitespace: String {
    return self.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined(separator: "")
  }
}
