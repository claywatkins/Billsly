//
//  Bill.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/3/21.
//

import Foundation

struct Bill: Codable, Equatable{
    var name: String
    var dollarAmount: Double
    var dueByDate: Date?
    var hasBeenPaid: Bool
    var category: String?
    var description: String?
    
    init(name: String,
         dollarAmount: Double,
         dueByDate: Date? = Date(),
         category: String? = nil,
         description: String? = nil) {
        
        self.name = name
        self.dollarAmount = dollarAmount
        self.dueByDate = dueByDate
        self.hasBeenPaid = false
        self.category = category
        self.description = description
    }
}
