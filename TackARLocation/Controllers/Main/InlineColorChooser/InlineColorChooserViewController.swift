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
//    cell.isSelected = true
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let color = self.colors[indexPath.row]
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
    
    self.colorContainerView.layer.cornerRadius = self.colorContainerView.bounds.height / 2
    self.colorContainerView.layer.masksToBounds = true
    self.colorContainerView.clipsToBounds = true
    self.colorView.layer.cornerRadius = self.colorView.bounds.height / 2
    self.colorView.layer.masksToBounds = true
    self.colorView.clipsToBounds = true
  }
  
  override var isSelected: Bool {
    didSet {
      self.update(isSelected: self.isSelected, animated: false)
    }
  }
  
  func update(isSelected: Bool, animated: Bool, completion: (() -> Void)? = nil) {
    guard self.isSelected != isSelected else { return }
    self.isSelected = isSelected
    self.colorViewHeightRelationConstraint.constant = isSelected ? -6 : 0
    self.colorViewWidthRelationConstraint.constant = isSelected ? -6 : 0
    if animated {
      UIView.animate(withDuration: 0.2, animations: { [weak self] in
        self?.layoutSubviews()
      }, completion: { _ in
        completion?()
      })
    } else {
      self.layoutSubviews()
      completion?()
    }
  }
}
