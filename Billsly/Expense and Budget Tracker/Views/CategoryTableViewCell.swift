//
//  CategoryTableViewCell.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/10/21.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    // MARK: - Properties
    var category: Category? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        categoryNameLabel.textColor = ColorsHelper.cultured
    }

    // MARK: - Methods
    private func updateViews() {
        categoryNameLabel.text = category?.name ?? "Unknown"
    }
}
