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
    @IBOutlet weak var addCategoryButton: UIButton!
    
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
    @IBAction func addCategoryButtonTapped(_ sender: Any) {
        let button = sender as? UIButton
        let buttonFrame = button?.frame ?? CGRect.zero
        
        let popoverContentController = self.storyboard?.instantiateViewController(withIdentifier: "CategoryPopoverViewController") as? CategoryPopoverViewController
        popoverContentController?.modalPresentationStyle = .popover
        
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

extension AddExpenseViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return true
    }
}
