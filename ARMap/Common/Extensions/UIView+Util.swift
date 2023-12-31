//
//  UIView+Util.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

extension UIView {
  
  // MARK: - Adding to Container
  
  enum RelativeLayoutType {
    case safeArea, view
  }
  
  func addToContainer(_ containerView: UIView, atIndex index: Int? = nil, topMargin: CGFloat = 0, bottomMargin: CGFloat = 0, leadingMargin: CGFloat = 0, trailingMargin: CGFloat = 0, relativeLayoutType: RelativeLayoutType = .view) {
    self.translatesAutoresizingMaskIntoConstraints = false
    self.frame = containerView.bounds
    
    if let index = index {
      containerView.insertSubview(self, at: index)
    } else {
      containerView.addSubview(self)
    }
    
    switch relativeLayoutType {
    case .safeArea:
      if #available(iOS 11, *) {
        let guide = containerView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
          self.topAnchor.constraint(equalTo: guide.topAnchor, constant: topMargin),
          guide.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottomMargin),
          self.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: leadingMargin),
          guide.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: trailingMargin)
          ])
      } else {
        NSLayoutConstraint.activate([
          self.topAnchor.constraint(equalTo: containerView.topAnchor, constant: topMargin),
          containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottomMargin),
          self.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leadingMargin),
          containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: trailingMargin)
          ])
      }
    case .view:
      let top = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: topMargin)
      let bottom = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: bottomMargin)
      let leading = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1, constant: leadingMargin)
      let trailing = NSLayoutConstraint(item: containerView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: trailingMargin)
      containerView.addConstraints([ top, bottom, leading, trailing ])
    }
    
    containerView.layoutIfNeeded()
  }
}
