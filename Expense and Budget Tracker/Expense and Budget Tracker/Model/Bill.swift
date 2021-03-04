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
    var dueByDate: Date
    var hasBeenPaid: Bool
    var category: String?
    var description: String?
}
