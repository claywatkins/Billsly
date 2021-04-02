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
    @IBOutlet weak var billNameLabel: UILabel!
    @IBOutlet weak var billNameTextField: UITextField!
    @IBOutlet weak var dollarAmountLabel: UILabel!
    @IBOutlet weak var dollarAmountTextField: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var addCategoryButton: UIButton!
    @IBOutlet weak var dateDueLabel: UILabel!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var fsCalendarView: FSCalendar!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var saveBillButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Properties
    var userController = UserController.shared
    var amt = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendar()
        addDoneButtonOnKeyboard()
        configureViews()
        self.hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Methods
    private func setupCalendar(){
        fsCalendarView.today = nil
        fsCalendarView.placeholderType = .none
        fsCalendarView.appearance.weekdayTextColor = ColorsHelper.powderBlue
        fsCalendarView.appearance.headerTitleColor = ColorsHelper.powderBlue
        fsCalendarView.calendarHeaderView.tintColor = ColorsHelper.powderBlue
        fsCalendarView.backgroundColor = ColorsHelper.slateGray
        fsCalendarView.appearance.selectionColor = ColorsHelper.celadonGreen
        fsCalendarView.layer.cornerRadius = 12
    }
    
    private func configureViews() {
        contentView.backgroundColor = ColorsHelper.blackCoral
        view.backgroundColor = ColorsHelper.blackCoral
        billNameLabel.textColor = ColorsHelper.cultured
        billNameTextField.textColor = ColorsHelper.cultured
        billNameTextField.backgroundColor = ColorsHelper.slateGray
        billNameTextField.layer.borderWidth = 1
        billNameTextField.layer.borderColor = ColorsHelper.apricot.cgColor
        billNameTextField.layer.cornerRadius = 8
        billNameTextField.attributedPlaceholder = NSAttributedString(string: "Bill Name",
                                                                     attributes: [NSAttributedString.Key.foregroundColor : ColorsHelper.cultured])
        dollarAmountLabel.textColor = ColorsHelper.cultured
        dollarAmountTextField.textColor = ColorsHelper.cultured
        dollarAmountTextField.backgroundColor = ColorsHelper.slateGray
        dollarAmountTextField.layer.borderWidth = 1
        dollarAmountTextField.layer.borderColor = ColorsHelper.apricot.cgColor
        dollarAmountTextField.layer.cornerRadius = 8
        dollarAmountTextField.attributedPlaceholder = NSAttributedString(string: "Dollar Amount",
                                                                         attributes: [NSAttributedString.Key.foregroundColor : ColorsHelper.cultured])
        categoryLabel.textColor = ColorsHelper.cultured
        categoryTextField.textColor = ColorsHelper.cultured
        categoryTextField.backgroundColor = ColorsHelper.slateGray
        categoryTextField.layer.borderWidth = 1
        categoryTextField.layer.borderColor = ColorsHelper.apricot.cgColor
        categoryTextField.layer.cornerRadius = 8
        categoryTextField.attributedPlaceholder = NSAttributedString(string: "Tap + to add a category or create your own",
                                                                     attributes: [NSAttributedString.Key.foregroundColor : ColorsHelper.cultured])
        addCategoryButton.tintColor = ColorsHelper.cultured
        
        dateDueLabel.textColor = ColorsHelper.cultured
        selectedDateLabel.textColor = ColorsHelper.cultured
        
        saveBillButton.configureButton(ColorsHelper.slateGray)
    }
    
    private func updateAmount() -> String? {
        userController.nf.numberStyle = .currency
        userController.nf.locale = Locale.current
        let amount = Double(amt/100) + Double (amt%100)/100
        return userController.nf.string(from: NSNumber(value: amount))
    }
    
    private func convertCurrencyToDouble(input: String) -> Double? {
        userController.nf.numberStyle = .currency
        userController.nf.locale = Locale.current
        return userController.nf.number(from: input)?.doubleValue
    }
    
    private func addDoneButtonOnKeyboard() {
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
    
    private func presentAlertController(missing: String) -> UIAlertController {
        let ac = UIAlertController(title: "Missing \(missing)", message: "Please add a \(missing.lowercased()) to continue", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        return ac
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
        let id = UUID().uuidString
        guard let name = billNameTextField.text, !name.isEmpty else {
            let ac = presentAlertController(missing: "Name")
            return present(ac, animated: true)
        }
        guard let amount = dollarAmountTextField.text, !amount.isEmpty else {
            let ac = presentAlertController(missing: "Dollar Amount")
            return present(ac, animated: true)
        }
        guard let finalAmount = convertCurrencyToDouble(input: amount) else { return }
        guard let category = categoryTextField.text, !category.isEmpty else {
            let ac = presentAlertController(missing: "Category")
            return present(ac, animated: true)
        }
        guard let date = selectedDateLabel.text else { return }
        guard let saveableDate = userController.df.date(from: date) else {
            let ac = presentAlertController(missing: "Date")
            return present(ac, animated: true)
        }
        
        var billDate: Int {
            userController.df.dateFormat = "d"
            return Int(userController.df.string(from: saveableDate))!
        }
        
        var isOn30th: Bool {
            if billDate == 30 {
                return true
            }
            return false
        }
        
        
        userController.createBill(identifier: id,
                                  name: name,
                                  dollarAmount: finalAmount,
                                  dueByDate: saveableDate,
                                  category: Category(name: category),
                                  isOn30th: isOn30th)
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Extension
extension AddBillViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        userController.df.dateFormat = "EEEE, MMM d, yyyy"
        selectedDateLabel.text = userController.df.string(from: date)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return ColorsHelper.cultured
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return fsCalendarView.currentPage.endOfMonth
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return fsCalendarView.currentPage.startOfMonth
    }
}

extension AddBillViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension AddBillViewController: CategoryCellTapped {
    func categoryCellTapped(name: String) {
        categoryTextField.text = name
    }
}

extension AddBillViewController: UITextFieldDelegate {
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
