//
//  AddExpenseViewController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/8/21.
//

import UIKit
import FSCalendar

class AddExpenseViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var expenseNameTextField: UITextField!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var dollarAmountTextFIeld: UITextField!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var calendarView: FSCalendar!
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Methods
    
    // MARK: - IBActions
    @IBAction func addCategoryButtonTapped(_ sender: Any) {
    }
    @IBAction func saveExpenseButtonTapped(_ sender: Any) {
    }
    
}

// MARK: - Extension
extension AddExpenseViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        <#code#>
    }
}
