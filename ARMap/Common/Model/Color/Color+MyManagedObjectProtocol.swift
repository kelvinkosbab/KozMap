//
//  Color+MyManagedObjectProtocol.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/6/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

extension UIColor {
  static let kozRed = UIColor(red: 208 / 255, green: 2 / 255, blue: 100 / 255, alpha: 1)
  static let kozOrange = UIColor(red: 245 / 255, green: 166 / 255, blue: 35 / 255, alpha: 1)
  static let kozYellow = UIColor(red: 248 / 255, green: 231 / 255, blue: 28 / 255, alpha: 1)
  static let kozGreen = UIColor(red: 45 / 255, green: 204 / 255, blue: 168 / 255, alpha: 1)
  static let kozBlue = UIColor(red: 45 / 255, green: 144 / 255, blue: 226 / 255, alpha: 1)
  static let kozPurple = UIColor(red: 116 / 255, green: 0 / 255, blue: 255 / 255, alpha: 1)
}

extension Color : MyManagedObjectProtocol {
  
  // MARK: - MyManagedObjectProtocol
  
  static var sortDescriptors: [NSSortDescriptor] {
    return [ NSSortDescriptor(key: "red", ascending: true), NSSortDescriptor(key: "green", ascending: true), NSSortDescriptor(key: "blue", ascending: true), NSSortDescriptor(key: "alpha", ascending: true) ]
  }
  
  // MARK: - Static Utilites
  
  static var red: Color {
    let color = Color.create()
    color.color = UIColor.kozRed
    return color
  }
  
  static var orange: Color {
    let color = Color.create()
    color.color = UIColor.kozOrange
    return color
  }
  
  static var yellow: Color {
    let color = Color.create()
    color.color = UIColor.kozYellow
    return color
  }
  
  static var green: Color {
    let color = Color.create()
    color.color = UIColor.kozGreen
    return color
  }
  
  static var blue: Color {
    let color = Color.create()
    color.color = UIColor.kozBlue
    return color
  }
  
  static var purple: Color {
    let color = Color.create()
    color.color = UIColor.kozPurple
    return color
  }
  
  static var white: Color {
    let color = Color.create()
    color.color = .white
    return color
  }
  
  static var black: Color {
    let color = Color.create()
    color.color = .black
    return color
  }
  
  // MARK: - Helpers
  
  var color: UIColor {
    get {
      return UIColor(red: CGFloat(self.red) / 255, green: CGFloat(self.green) / 255, blue: CGFloat(self.blue) / 255, alpha: CGFloat(self.alpha))
    }
    set {
      self.red = Int16(newValue.rgbRed)
      self.green = Int16(newValue.rgbGreen)
      self.blue = Int16(newValue.rgbBlue)
      self.alpha = Float(newValue.rgbAlpha)
    }
  }
}
