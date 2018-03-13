//
//  String+UIKit.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/13/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

extension String {
  
  func calculateHeight(forLabel label: UILabel) -> CGFloat {
    let width = label.bounds.width
    let font = label.font
    return self.calculateHeight(expectedWidth: width, font: font!)
  }
  
  func calculateHeight(expectedWidth width: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
    return boundingBox.height + 20
  }
  
  func calculateSize(font: UIFont) -> CGSize {
    return (self as NSString).size(withAttributes: [ NSAttributedStringKey.font : font ])
  }
  
  func calculateWidth(font: UIFont) -> CGFloat {
    return self.calculateSize(font: font).width
  }
}
