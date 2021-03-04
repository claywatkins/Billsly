//
//  Expense.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/3/21.
//

import Foundation

struct Expense: Codable, Equatable{
    var name: String
    var dollarAmount: Double
    var description: String?
    var category: String?
    
    internal init(name: String, dollarAmount: Double, description: String? = nil, category: String? = nil) {
        self.name = name
        self.dollarAmount = dollarAmount
        self.description = description
        self.category = category
    }
}
