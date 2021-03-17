//
//  Category.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/10/21.
//

import UIKit

struct Category: Codable, Equatable {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
