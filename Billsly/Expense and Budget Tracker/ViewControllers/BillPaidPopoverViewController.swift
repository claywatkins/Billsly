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
        configureViews()
        currentBillSelection = userController.unpaidBills[0]
    }

    // MARK: - Methods
    private func configureViews() {
        view.backgroundColor = ColorsHelper.blackCoral
        pickerView.backgroundColor = ColorsHelper.slateGray
        pickerView.layer.cornerRadius = 15
        whatBillLabel.textColor = ColorsHelper.cultured
        paidButton.configureButton(ColorsHelper.slateGray)
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
        
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: userController.unpaidBills[row].name, attributes: [NSAttributedString.Key.foregroundColor: ColorsHelper.cultured])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentBillSelection = userController.unpaidBills[row]
    }
}
