//
//  Loggable.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation

protocol Loggable : class {}
extension NSObject : Loggable {}
extension Loggable {
  
  // MARK: - Static
  
  static var isLoggingEnabled: Bool {
    return true
  }
  
  static func log(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
    if self.isLoggingEnabled {
      print("\(self.stackCallerClassAndMethodString(file: file, line: line, function: function)) - \(message)")
    }
  }
  
  private static func stackCallerClassAndMethodString(file: String, line: Int, function: String) -> String {
    let lastPathComponent = (file as NSString).lastPathComponent
    return "\(lastPathComponent):\(line) : \(function)"
  }
  
  // MARK: - Non-Static
  
  var isLoggingEnabled: Bool {
    return true
  }
  
  private func stackCallerClassAndMethodString(file: String, line: Int, function: String) -> String {
    let lastPathComponent = (file as NSString).lastPathComponent
    return "\(lastPathComponent):\(line) : \(function)"
  }
  
  func log(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
    if self.isLoggingEnabled {
      print("\(self.stackCallerClassAndMethodString(file: file, line: line, function: function)) - \(message)")
    }
  }
  
  func extendedLog(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
    if self.isLoggingEnabled {
      print("\n<<< ✅✅✅ \(self.stackCallerClassAndMethodString(file: file, line: line, function: function)) : \(message) ✅✅✅ >>>\n")
    }
  }
  
  func logMethodExecution(file: String = #file, line: Int = #line, function: String = #function) {
    if self.isLoggingEnabled {
      print("\n<<< ✅✅✅ \(self.stackCallerClassAndMethodString(file: file, line: line, function: function)) ✅✅✅ >>>\n")
    }
  }
  
  func logMethodExecution(emoji: String, file: String = #file, line: Int = #line, function: String = #function) {
    if self.isLoggingEnabled {
      print("\n<<< \(emoji) \(self.stackCallerClassAndMethodString(file: file, line: line, function: function)) \(emoji) >>>\n")
    }
  }
  
  func logFullStackData() {
    if self.isLoggingEnabled {
      let sourceString = Thread.callStackSymbols[1]
      let separatorSet = CharacterSet.init(charactersIn: " -[]+?.,")
      let array = sourceString.components(separatedBy: separatorSet)
      
      print("****** Stack: \(array[0])")
      print("****** Framework: \(array[1])")
      print("****** Memory address: \(array[2])")
      print("****** Class caller: \(array[3])")
      print("****** Function caller: \(array[4])")
      print("****** Line caller: \(array[5])")
    }
  }
}
