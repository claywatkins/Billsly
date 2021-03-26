//
//  Bill.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/3/21.
//

import Foundation

struct Bill: Codable, Equatable{
    var identifier: String
    var name: String
    var dollarAmount: Double
    var dueByDate: Date
    var hasBeenPaid: Bool
    var category: Category
    var hasReminder: Bool
    
    init(identifier: String,
         name: String,
         dollarAmount: Double,
         dueByDate: Date,
         category: Category,
         hasReminder: Bool) {
        self.identifier = identifier
        self.name = name
        self.dollarAmount = dollarAmount
        self.dueByDate = dueByDate
        self.hasBeenPaid = false
        self.category = category
        self.hasReminder = hasReminder
    }
}
