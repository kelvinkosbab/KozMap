//
//  InlineColorChooserViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/6/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

protocol InlineColorChooserViewControllerDelegate : class {
  func didSelect(color: UIColor)
}

class InlineColorChooserViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout, BatchUpdatable {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> InlineColorChooserViewController {
    return self.newViewController(fromStoryboardWithName: "InlineColorChooser")
  }
  
  static func newViewController(delegate: InlineColorChooserViewControllerDelegate) -> InlineColorChooserViewController {
    let viewController = self.newViewController()
    viewController.delegate = delegate
    return viewController
  }
  
  // MARK: - BatchUpdatable
  
  var isProcessingBatchUpdate: Bool = false
  var batchUpdateQueue: [BatchUpdatableItem] = []
  
  // MARK: - Properties
  
  weak var delegate: InlineColorChooserViewControllerDelegate? = nil
  let colors: [UIColor] = [ .kozRed, .kozOrange, .kozYellow, .kozGreen, .kozBlue, .kozPurple ]
  
  var selectedColor: UIColor = .kozRed {
    didSet {
      
      guard self.isViewLoaded && self.selectedColor != oldValue else {
        return
      }
      
      var indexPathsToUpdate: [IndexPath] = []
      if let index = self.colors.index(of: self.selectedColor) {
        let indexPath = IndexPath(row: index, section: 0)
        indexPathsToUpdate.append(indexPath)
      }
      
      if let index = self.colors.index(of: oldValue) {
        let indexPath = IndexPath(row: index, section: 0)
        indexPathsToUpdate.append(indexPath)
      }
      
      self.collectionView?.reloadItems(at: indexPathsToUpdate)
    }
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.collectionView?.delegate = self
    self.collectionView?.dataSource = self
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    // Update the layout parameters for the collection view
    self.adjustedTotalViewWidth = self.view.bounds.width
  }
  
  // MARK: - SectionType
  
  enum SectionType {
    case colors([UIColor])
  }
  
  func getSectionType(section: Int) -> SectionType? {
    switch section {
    case 0:
      return .colors(self.colors)
    default:
      return nil
    }
  }
  
  // MARK: - RowType
  
  enum RowType {
    case color(UIColor)
  }
  
  func getRowType(at indexPath: IndexPath) -> RowType? {
    
    guard let sectionType = self.getSectionType(section: indexPath.section) else {
      return nil
    }
    
    switch sectionType {
    case .colors(let colors):
      if indexPath.row < colors.count {
        let color = colors[indexPath.row]
        return .color(color)
      }
      return nil
    }
  }
  
  // MARK: - UICollectionView
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    guard let sectionType = self.getSectionType(section: section) else {
      return 0
    }
    
    switch sectionType {
    case .colors(let colors):
      return colors.count
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InlineColorChooserCollectionViewCell", for: indexPath) as! InlineColorChooserCollectionViewCell
    
    guard let rowType = self.getRowType(at: indexPath) else {
      cell.colorView.backgroundColor = .clear
      cell.update(isSelected: false, animated: false)
      return cell
    }
    
    switch rowType {
    case .color(let color):
      cell.colorView.backgroundColor = color
      cell.update(isSelected: self.selectedColor == color, animated: false)
      return cell
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    guard let rowType = self.getRowType(at: indexPath) else {
      return
    }
    
    switch rowType {
    case .color(let color):
      
      // Selected color
      self.selectedColor = color
      
      // Notify the delegate
      self.delegate?.didSelect(color: color)
    }
  }
  
  // MARK: - UICollectionViewDelegateFlowLayout
  
  var adjustedTotalViewWidth: CGFloat = UIScreen.main.bounds.width {
    didSet {
      if self.isViewLoaded, self.adjustedTotalViewWidth != oldValue {
        self.collectionView?.collectionViewLayout.invalidateLayout()
      }
    }
  }
  
  var cellDimension: CGFloat {
    let desiredWidth = self.adjustedTotalViewWidth / CGFloat(self.colors.count)
    return min(desiredWidth, self.view.bounds.height)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cellDimension = self.cellDimension
    return CGSize(width: cellDimension, height: cellDimension)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    
    // Asks the delegate for the spacing between successive rows or columns of a section.
    let cellDimension = self.cellDimension
    let totalCellWidth = cellDimension * CGFloat(self.colors.count)
    let remainingWidth = self.adjustedTotalViewWidth - totalCellWidth
    let desiredSpacing = remainingWidth / CGFloat(self.colors.count - 1)
    return desiredSpacing
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    // Asks the delegate for the spacing between successive items in the rows or columns of a section.
    return 0
  }
}

// MARK: - InlineColorChooserCollectionViewCell

class InlineColorChooserCollectionViewCell : UICollectionViewCell {
  @IBOutlet weak var colorView: UIView!
  @IBOutlet weak var selectedCircleView: UIImageView!
  @IBOutlet weak var selectedCircleViewHeight: NSLayoutConstraint!
  @IBOutlet weak var selectedCircleViewWidth: NSLayoutConstraint!
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.colorView.layer.cornerRadius = self.colorView.layer.bounds.height / 2
    self.colorView.layer.masksToBounds = true
    self.colorView.clipsToBounds = true
  }
  
  func update(isSelected: Bool, animated: Bool) {
    self.isSelected = isSelected
    let toDimension: CGFloat = isSelected ? 20 : 0
    let toAlpha: CGFloat = isSelected ? 0.75 : 0
    if animated {
      UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
        self?.selectedCircleView.alpha = toAlpha
        self?.selectedCircleViewHeight.constant = toDimension
        self?.selectedCircleViewWidth.constant = toDimension
      }, completion: nil)
    } else {
      self.selectedCircleView.alpha = toAlpha
      self.selectedCircleViewHeight.constant = toDimension
      self.selectedCircleViewWidth.constant = toDimension
      self.layoutSubviews()
    }
  }
}
