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
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var dollarAmountTextFIeld: UITextField!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var calendarView: FSCalendar!
    
    // MARK: - Properties
    let df = DateFormatter()
    let picker = UIPickerView()
    let toolBar = UIToolbar()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    // MARK: - Methods
    private func updateViews(){
        df.dateFormat = "MM-dd-yyyy"
        selectedDateLabel.text = df.string(from: Date())
    }
    

    // MARK: - IBActions
    
    @IBAction func saveExpenseButtonTapped(_ sender: Any) {
        
    }
    
}

// MARK: - Extension
extension AddExpenseViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        selectedDateLabel.text = dateFormatter.string(from: date)
    }
}
