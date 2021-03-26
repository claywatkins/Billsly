//
//  EditBillViewController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/11/21.
//

import UIKit
import FSCalendar
import UserNotifications

class EditBillViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var billNameLabel: UILabel!
    @IBOutlet weak var billNameTextField: UITextField!
    @IBOutlet weak var dollarAmountLabel: UILabel!
    @IBOutlet weak var dollarAmountTextField: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var addCategoryButton: UIButton!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var dateDueLabel: UILabel!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var fsCalendarView: FSCalendar!
    @IBOutlet weak var updateBillButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    // MARK: - Properties
    var userController = UserController.shared
    var bill: Bill?
    var amt = 0
    var delegate: CategoryCellTapped?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        configureViews()
        configureCalendar()
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
        userController.nf.numberStyle = .currency
        dollarAmountTextField.text = userController.nf.string(from: NSNumber(value: bill.dollarAmount))
        categoryTextField.text = bill.category.name
        userController.df.dateFormat = "EEEE, MMM d, yyyy"
        selectedDateLabel.text = userController.df.string(from: bill.dueByDate)
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
        updateBillButton.configureButton(ColorsHelper.slateGray)
    }
    
    private func configureCalendar() {
        fsCalendarView.today = nil
        fsCalendarView.placeholderType = .none
        fsCalendarView.appearance.weekdayTextColor = ColorsHelper.powderBlue
        fsCalendarView.appearance.headerTitleColor = ColorsHelper.powderBlue
        fsCalendarView.calendarHeaderView.tintColor = ColorsHelper.powderBlue
        fsCalendarView.backgroundColor = ColorsHelper.slateGray
        fsCalendarView.appearance.selectionColor = ColorsHelper.celadonGreen
        fsCalendarView.layer.cornerRadius = 12
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
    
    private func presentAlertController(missing: String) -> UIAlertController {
        let ac = UIAlertController(title: "Missing \(missing)", message: "Please add a \(missing.lowercased()) to continue", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        return ac
    }
    
    // MARK: IBActions
    @IBAction func updateBillButtonTapped(_ sender: Any) {
        guard let bill = bill else { return }
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
//        var billDate: Int {
//            userController.df.dateFormat = "d"
//            return Int(userController.df.string(from: saveableDate))!
//        }
//        
//        if bill.dueByDate != saveableDate {
//            let center = UNUserNotificationCenter.current()
//            center.removePendingNotificationRequests(withIdentifiers: [bill.identifier])
//            if saveableDate <= Date(){
//                if UserDefaults.standard.bool(forKey: "ShowAlert") == true {
//                    let ac = UIAlertController(title: "Date Warning", message: "Due Date is scheduled for today or before today, you will not recieve a notification about this bill this month.", preferredStyle: .alert)
//                    ac.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
//                        self.navigationController?.popViewController(animated: true)
//                    }))
//                    ac.addAction(UIAlertAction(title: "Don't Show This Alert Again", style: .default, handler: { _ in
//                        UserDefaults.standard.setValue(false, forKey: "ShowAlert")
//                        self.navigationController?.popViewController(animated: true)
//                    }))
//                    self.present(ac, animated: true)
//                }
//            } else {
//                let content = UNMutableNotificationContent()
//                content.title = "Upcoming Bill Due"
//                content.body = "\(name) will be due soon, make sure to mark it as paid after paying it!"
//                
//                var dateComponents = DateComponents()
//                dateComponents.calendar = Calendar.current
////                dateComponents.timeZone = TimeZone.current
//                if billDate <= 5 {
//                    dateComponents.hour = 11
//                    switch billDate {
//                    case 1:
//                        dateComponents.day = 1
//                    case 2:
//                        dateComponents.day = -1
//                    case 3:
//                        dateComponents.day = -2
//                    case 4:
//                        dateComponents.day = -3
//                    case 5:
//                        dateComponents.day = -4
//                    default:
//                        dateComponents.day = billDate
//                    }
//                } else if saveableDate.days(from: dateComponents.date!) <= 5{
//                    print(dateComponents.date!)
//                    print(saveableDate.days(from: dateComponents.date!))
//                    dateComponents.day = billDate - 5
//                    dateComponents.hour = 11
//                }
//                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//                let request = UNNotificationRequest(identifier: bill.identifier,
//                                                    content: content,
//                                                    trigger: trigger)
//                let center = UNUserNotificationCenter.current()
//                center.add(request) { (error) in
//                    if let error = error {
//                        print("Error: \(error.localizedDescription)")
//                    }
//                }
//            }
//        }
        
        userController.updateBillData(bill: bill,
                                      name: name,
                                      dollarAmount: finalAmount,
                                      dueByDate: saveableDate,
                                      category: Category(name: category),
                                      hasReminder: false)
        
        
        
        self.navigationController?.popViewController(animated: true)
    }
    
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
}

extension EditBillViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        userController.df.dateFormat = "EEEE, MMM d, yyyy"
        selectedDateLabel.text = userController.df.string(from: date)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return ColorsHelper.cultured
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

extension EditBillViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension EditBillViewController: CategoryCellTapped {
    func categoryCellTapped(name: String) {
        categoryTextField.text = name
    }
}
