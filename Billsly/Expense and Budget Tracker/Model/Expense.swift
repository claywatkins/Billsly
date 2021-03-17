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
    var category: Category?
    var date: Date?
    
    init(name: String, dollarAmount: Double, description: String? = nil, category: Category? = nil, date: Date? = Date()) {
        self.name = name
        self.dollarAmount = dollarAmount
        self.description = description
        self.category = category
        self.date = date
    }
    
    
}
