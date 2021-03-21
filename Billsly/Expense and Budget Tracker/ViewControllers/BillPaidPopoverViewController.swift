//
//  BillPaidPopoverViewController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/14/21.
//

import UIKit

protocol BillHasBeenPaid {
    func updateCalendar()
}

class BillPaidPopoverViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var whatBillLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var paidButton: UIButton!
    
    // MARK: - Properties
    let userController = UserController.shared
    var currentBillSelection: Bill?
    var delegate: BillHasBeenPaid?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        currentBillSelection = userController.unpaidBills[0]
    }

    // MARK: - IBActions
    @IBAction func paidButtonTapped(_ sender: Any) {
        userController.updateBillHasBeenPaid(bill: currentBillSelection!)
        delegate?.updateCalendar()
        self.dismiss(animated: true, completion: nil)
    }
}

extension BillPaidPopoverViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userController.unpaidBills.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return userController.unpaidBills[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentBillSelection = userController.unpaidBills[row]
    }
}
