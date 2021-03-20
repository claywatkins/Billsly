//
//  UIButtonExtension.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/19/21.
//

import UIKit

extension UIButton {
    func configureButton(_ color: UIColor?) {
        layer.cornerRadius = 15
        layer.shadowOpacity = 0.4
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.masksToBounds = false
        backgroundColor = color
    }
}
