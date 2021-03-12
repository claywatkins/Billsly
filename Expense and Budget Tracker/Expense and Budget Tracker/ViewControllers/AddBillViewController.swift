//
//  AddExpenseViewController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/8/21.
//

import UIKit
import FSCalendar

class AddBillViewController: UIViewController{
    
    // MARK: - IBOutlets
    @IBOutlet weak var billNameTextField: UITextField!
    @IBOutlet weak var dollarAmountTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var addCategoryButton: UIButton!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var fsCalendarView: FSCalendar!
    
    // MARK: - Properties
    let df = DateFormatter()
    let picker = UIPickerView()
    let toolBar = UIToolbar()
    let userController = UserController.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    // MARK: - Methods
    private func updateViews(){
        df.dateFormat = "EEEE, MMM d, yyyy"
        selectedDateLabel.text = df.string(from: Date())
    }
    
    
    // MARK: - IBActions
    @IBAction func addCategoryButtonTapped(_ sender: Any) {
        let popoverContentController = self.storyboard?.instantiateViewController(withIdentifier: "CategoryPopoverViewController") as? CategoryPopoverViewController
        popoverContentController?.modalPresentationStyle = .popover
        popoverContentController?.delegate = self
        
        if let popoverPresentationController = popoverContentController?.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .any
            popoverPresentationController.sourceView = addCategoryButton
            popoverPresentationController.sourceRect = CGRect(origin: addCategoryButton.center, size: .zero)
            popoverPresentationController.delegate = self
            if let popoverController = popoverContentController {
                present(popoverController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func saveBillButtonTapped(_ sender: Any) {
        guard let name = billNameTextField.text, !name.isEmpty else { return }
        guard let amount = dollarAmountTextField.text, !amount.isEmpty else { return }
        guard let amountDouble = Double(amount) else { return }
        guard let category = categoryTextField.text, !category.isEmpty else { return }
        guard let date = selectedDateLabel.text else { return }
        guard let saveableDate = df.date(from: date) else { return }
        
        userController.createBill(name: name,
                                  dollarAmount: amountDouble,
                                  dueByDate: saveableDate,
                                  category: Category(name: category))
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Extension
extension AddBillViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        selectedDateLabel.text = dateFormatter.string(from: date)
    }
}

extension AddBillViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
}

extension AddBillViewController: CategoryCellTapped {
    func categoryCellTapped(name: String) {
        categoryTextField.text = name
    }
}
