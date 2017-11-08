//
//  InlineColorChooserViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/6/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit

protocol InlineColorChooserViewControllerDelegate : class {
  func didSelect(color: UIColor)
}

class InlineColorChooserViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> InlineColorChooserViewController {
    return self.newViewController(fromStoryboardWithName: "Main")
  }
  
  static func newViewController(delegate: InlineColorChooserViewControllerDelegate) -> InlineColorChooserViewController {
    let viewController = self.newViewController()
    viewController.delegate = delegate
    return viewController
  }
  
  // MARK: - Properties
  
  weak var delegate: InlineColorChooserViewControllerDelegate? = nil
  let colors: [UIColor] = [ UIColor.kozRed, UIColor.kozOrange, UIColor.kozYellow, UIColor.kozGreen, UIColor.kozBlue, UIColor.kozPurple ]
  var selectedIndexPath: IndexPath = IndexPath(row: 0, section: 0) {
    didSet {
      if self.isViewLoaded {
        
        // De-select the old color
        if let cell = self.collectionView?.cellForItem(at: oldValue) as? InlineColorChooserCollectionViewCell {
          cell.update(isSelected: false, animated: true)
        }
        
        // Select the new color
        if let cell = self.collectionView?.cellForItem(at: self.selectedIndexPath) as? InlineColorChooserCollectionViewCell {
          cell.update(isSelected: true, animated: true)
        }
      }
    }
  }
  
  var selectedColor: UIColor {
    return self.colors[self.selectedIndexPath.row]
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.collectionView?.delegate = self
    self.collectionView?.dataSource = self
  }
  
  // MARK: - UICollectionView
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.colors.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InlineColorChooserCollectionViewCell", for: indexPath) as! InlineColorChooserCollectionViewCell
    let color = self.colors[indexPath.row]
    cell.colorView.backgroundColor = color
    cell.update(isSelected: self.selectedIndexPath == indexPath, animated: false)
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    // Selected color
    let color = self.colors[indexPath.row]
    self.selectedIndexPath = indexPath
    
    // Notify the delegate
    self.delegate?.didSelect(color: color)
  }
  
  // MARK: - UICollectionViewDelegateFlowLayout
  
  func getCellDimension(collectionView: UICollectionView) -> CGFloat {
    let desiredWidth = collectionView.bounds.width / CGFloat(self.colors.count)
    return min(desiredWidth, collectionView.bounds.height)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cellDimension = self.getCellDimension(collectionView: collectionView)
    return CGSize(width: cellDimension, height: cellDimension)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    // Asks the delegate for the spacing between successive rows or columns of a section.
    let cellDimension = self.getCellDimension(collectionView: collectionView)
    let totalCellWidth = cellDimension * CGFloat(self.colors.count)
    let remainingWidth = collectionView.bounds.width - totalCellWidth
    let desiredSpacing = remainingWidth / CGFloat(self.colors.count + 1)
    return max(0, desiredSpacing)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    // Asks the delegate for the spacing between successive items in the rows or columns of a section.
    return 0
  }
}

// MARK: - InlineColorChooserCollectionViewCell

class InlineColorChooserCollectionViewCell : UICollectionViewCell {
  @IBOutlet weak var colorContainerView: UIView!
  @IBOutlet weak var colorView: UIView!
  @IBOutlet weak var colorViewHeightRelationConstraint: NSLayoutConstraint!
  @IBOutlet weak var colorViewWidthRelationConstraint: NSLayoutConstraint!
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.colorContainerView.layer.cornerRadius = (self.colorContainerView.bounds.height - 5) / 2
    self.colorContainerView.layer.masksToBounds = true
    self.colorContainerView.clipsToBounds = true
    self.colorView.layer.cornerRadius = (self.colorView.bounds.height - 5) / 2
    self.colorView.layer.masksToBounds = true
    self.colorView.clipsToBounds = true
  }
  
  func update(isSelected: Bool, animated: Bool) {
    self.isSelected = isSelected
    self.colorViewHeightRelationConstraint.constant = isSelected ? -6 : 0
    self.colorViewWidthRelationConstraint.constant = isSelected ? -6 : 0
    if animated {
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [weak self] in
        self?.colorView.layoutSubviews()
      })
    } else {
      self.colorView.layoutSubviews()
    }
  }
}
