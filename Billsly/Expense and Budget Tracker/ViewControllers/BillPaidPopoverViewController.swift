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
    var userController = UserController.shared
    var currentBillSelection: Bill?
    var delegate: BillHasBeenPaid?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        currentBillSelection = userController.unpaidBills[0]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIAppearence()
    }
    // MARK: - Methods
    private func updateUIAppearence() {
        pickerView.layer.cornerRadius = 15
        let defaults = UserDefaults.standard
        let selection = defaults.integer(forKey: "appearanceSelection")
        switch selection {
        case 0:
            customUIAppearance()
        case 1:
            overrideUserInterfaceStyle = .dark
            darkLightMode()
        case 2:
            overrideUserInterfaceStyle = .light
            darkLightMode()
        case 3:
            overrideUserInterfaceStyle = .unspecified
            darkLightMode()
        default:
            print("Error")
            break
        }
    }
    private func customUIAppearance() {
        view.backgroundColor = ColorsHelper.blackCoral
        pickerView.backgroundColor = ColorsHelper.slateGray
        whatBillLabel.textColor = ColorsHelper.cultured
        paidButton.configureButton(ColorsHelper.slateGray)
    }
    private func darkLightMode() {
        view.backgroundColor = UIColor(named: "background")
        pickerView.backgroundColor = UIColor(named: "foreground")
        whatBillLabel.textColor = UIColor(named: "text")
        paidButton.configureButton(UIColor(named: "foreground"))
        paidButton.setTitleColor(UIColor(named: "text"), for: .normal)
    }
    
    // MARK: - IBActions
    @IBAction func paidButtonTapped(_ sender: Any) {
        userController.updateBillHasBeenPaid(bill: currentBillSelection!)
        delegate?.updateCalendar()
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Extension
extension BillPaidPopoverViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userController.unpaidBills.count
    }
        
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: userController.unpaidBills[row].name, attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "text")!])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentBillSelection = userController.unpaidBills[row]
    }
}
