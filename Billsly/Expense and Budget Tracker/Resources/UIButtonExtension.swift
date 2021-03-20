//
//  UIButtonExtension.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/19/21.
//

import UIKit

extension UIButton {
    func configureView(color: UIColor?) {
        layer.cornerRadius = 15
        layer.shadowOpacity = 0.7
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.masksToBounds = false
        backgroundColor = color
    }
}
