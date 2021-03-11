//
//  CategoryCollectionViewCell.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/10/21.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    // MARK: - Properties
    var category: Category? {
        didSet{
            updateViews()
        }
    }
    
    // MARK: - Methods
    private func updateViews() {
        categoryNameLabel.text = category?.name ?? "Unknown"
    }
}
