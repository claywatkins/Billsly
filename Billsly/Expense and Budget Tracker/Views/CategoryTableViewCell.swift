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
            updateText()
        }
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        updateUIAppearence()
    }

    // MARK: - Methods
    private func updateText() {
        categoryNameLabel.text = category?.name ?? "Unknown"
    }
    
    private func updateUIAppearence() {
        let defaults = UserDefaults.standard
        let selection = defaults.integer(forKey: "appearanceSelection")
        switch selection {
        case 0:
            customUIAppearance()
        case 1:
            overrideUserInterfaceStyle = .dark
            darkLightMode()
        case 2:
            overrideUserInterfaceStyle = .light
            darkLightMode()
        case 3:
            overrideUserInterfaceStyle = .unspecified
            darkLightMode()
        default:
            print("Error")
            break
        }
    }
    private func customUIAppearance(){
        categoryNameLabel.textColor = ColorsHelper.cultured
        contentView.backgroundColor = ColorsHelper.slateGray
    }
    private func darkLightMode(){
        categoryNameLabel.textColor = UIColor(named: "text")
        contentView.backgroundColor = UIColor(named: "foreground")
    }
}
