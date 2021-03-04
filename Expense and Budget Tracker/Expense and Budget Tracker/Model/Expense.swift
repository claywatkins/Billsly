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
}
