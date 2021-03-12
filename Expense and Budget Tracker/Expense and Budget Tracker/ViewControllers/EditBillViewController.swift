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
    var amt = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        addDoneButtonOnKeyboard()
        self.hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Methods
    private func updateViews() {
        guard let bill = bill else { return }
        fsCalendarView.select(bill.dueByDate)
        fsCalendarView.today = nil
        navigationItem.title = bill.name
        billNameTextField.text = bill.name
        dollarAmountTextField.text = userController.nf.string(from: NSNumber(value: bill.dollarAmount))
        categoryTextField.text = bill.category.name
        userController.df.dateFormat = "EEEE, MMM d, yyyy"
        selectedDateLabel.text = userController.df.string(from: bill.dueByDate)
    }
    
    
    
    func updateAmount() -> String? {
        userController.nf.numberStyle = .currency
        userController.nf.locale = Locale.current
        let amount = Double(amt/100) + Double (amt%100)/100
        return userController.nf.string(from: NSNumber(value: amount))
    }
    
    func convertCurrencyToDouble(input: String) -> Double? {
        userController.nf.numberStyle = .currency
        userController.nf.locale = Locale.current
        return userController.nf.number(from: input)?.doubleValue
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(AddBillViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.dollarAmountTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.dollarAmountTextField.resignFirstResponder()
    }
    
    // MARK: IBActions
    @IBAction func updateBillButtonTapped(_ sender: Any) {
        guard let bill = bill else { return }
        guard let name = billNameTextField.text, !name.isEmpty else { return }
        guard let amount = dollarAmountTextField.text, !amount.isEmpty else { return }
        guard let finalAmount = convertCurrencyToDouble(input: amount) else { return }
        guard let category = categoryTextField.text, !category.isEmpty else { return }
        guard let date = selectedDateLabel.text else { return }
        guard let saveableDate = userController.df.date(from: date) else { return }
        
        userController.updateBillData(bill: bill,
                                      name: name,
                                      dollarAmount: finalAmount,
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

extension EditBillViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == dollarAmountTextField{
            if let digit = Int(string) {
                amt = amt * 10 + digit
                dollarAmountTextField.text = updateAmount()
            }
            if string == "" {
                amt = amt/10
                dollarAmountTextField.text = updateAmount()
            }
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
