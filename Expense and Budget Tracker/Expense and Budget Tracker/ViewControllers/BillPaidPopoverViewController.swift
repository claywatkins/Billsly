//
//  BillPaidPopoverViewController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/14/21.
//

import UIKit

class BillPaidPopoverViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var pickerView: UIPickerView!
    
    // MARK: - Properties
    let userController = UserController.shared
    var currentBillSelection: Bill?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        currentBillSelection = userController.unpaidBills[0]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pickerView.reloadInputViews()
    }
    
    // MARK: - Methods
    
    // MARK: - IBActions
    @IBAction func paidButtonTapped(_ sender: Any) {

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
