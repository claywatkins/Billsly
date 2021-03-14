//
//  BillTableViewCell.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/4/21.
//

import UIKit

protocol BillTableViewCellDelegate {
    func toggleHasBeenPaid(for cell: BillTableViewCell)
}

class BillTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var billName: UILabel!
    @IBOutlet weak var paidUnpaidButton: UIButton!
    @IBOutlet weak var dateDueLabel: UILabel!
    
    // MARK: - Properties
    var bill: Bill? {
        didSet{
            updateViews()
        }
    }
    var delegate: BillTableViewCellDelegate?
    let userController = UserController.shared
    
    // MARK: - Private Methods
    private func updateViews(){
        guard let bill = bill else { return }
        billName.text = bill.name
        userController.df.dateFormat = "MMM d, yyyy"
        dateDueLabel.text = userController.df.string(from: bill.dueByDate)
        if bill.hasBeenPaid {
            paidUnpaidButton.setImage(UIImage(systemName: "checkmark.seal.fill"), for: .normal)
        } else {
            paidUnpaidButton.setImage(UIImage(systemName: "checkmark.seal"), for: .normal)
        }
    }
    
    // MARK: - IBAction
    @IBAction func billPaidButtonTapped(_ sender: Any) {
        delegate?.toggleHasBeenPaid(for: self)
    }
}
