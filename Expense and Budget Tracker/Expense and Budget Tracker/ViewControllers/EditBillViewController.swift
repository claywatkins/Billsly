//
//  EditBillViewController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/11/21.
//

import UIKit
import FSCalendar

class EditBillViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var billNameTextField: UITextField!
    @IBOutlet weak var dollarAmountTextField: UITextField!
    @IBOutlet weak var addCategoryButton: UIButton!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var fsCalendarView: FSCalendar!
    
    // MARK: - Properties
    let userController = UserController.shared
    var bill: Bill?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    // MARK: - Methods
    private func updateViews() {
        guard let bill = bill else { return }
        navigationItem.title = bill.name
        billNameTextField.text = bill.name
        dollarAmountTextField.text = String(bill.dollarAmount)
        categoryTextField.text = bill.category.name
        userController.df.dateFormat = "EEEE, MMM d, yyyy"
        selectedDateLabel.text = userController.df.string(from: bill.dueByDate)
    }
    
    // MARK: IBActions
    @IBAction func updateBillButtonTapped(_ sender: Any) {
        guard let bill = bill else { return }
        guard let name = billNameTextField.text, !name.isEmpty else { return }
        guard let amount = dollarAmountTextField.text, !amount.isEmpty else { return }
        guard let amountDouble = Double(amount) else { return }
        guard let category = categoryTextField.text, !category.isEmpty else { return }
        guard let date = selectedDateLabel.text else { return }
        guard let saveableDate = userController.df.date(from: date) else { return }
        
        userController.updateBillData(bill: bill,
                                      name: name,
                                      dollarAmount: amountDouble,
                                      dueByDate: saveableDate,
                                      category: Category(name: category))
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension EditBillViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        userController.df.dateFormat = "EEEE, MMM d, yyyy"
        selectedDateLabel.text = userController.df.string(from: date)
    }
    
    
    
}
