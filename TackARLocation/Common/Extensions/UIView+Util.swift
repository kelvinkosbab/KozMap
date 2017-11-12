//
//  UIView+Util.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit

extension UIView {
  
  func addToContainer(_ containerView: UIView, atIndex index: Int? = nil, topMargin: CGFloat = 0, bottomMargin: CGFloat = 0, leadingMargin: CGFloat = 0, trailingMargin: CGFloat = 0) {
    self.translatesAutoresizingMaskIntoConstraints = false
    self.frame = containerView.frame
    
    if let index = index {
      containerView.insertSubview(self, at: index)
    } else {
      containerView.addSubview(self)
    }
    
    if #available(iOS 11, *) {
      let guide = containerView.safeAreaLayoutGuide
      NSLayoutConstraint.activate([
        self.topAnchor.constraint(equalTo: guide.topAnchor, constant: 0),
        guide.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
        self.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 0),
        guide.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
        ])
    } else {
      NSLayoutConstraint.activate([
        self.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
        containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
        self.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
        ])
    }
    containerView.layoutIfNeeded()
  }
}
