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
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        billName.textColor = ColorsHelper.cultured
        dateDueLabel.textColor = ColorsHelper.cultured
    }
    
    // MARK: - Private Methods
    private func updateViews(){
        guard let bill = bill else { return }
        billName.text = bill.name
        userController.df.dateFormat = "MMM d, yyyy"
        dateDueLabel.text = userController.df.string(from: bill.dueByDate)
        if bill.hasBeenPaid {
            let config = UIImage.SymbolConfiguration(pointSize: 32)
            let image = UIImage(systemName: "checkmark.seal.fill", withConfiguration: config)
            paidUnpaidButton.setImage(image, for: .normal)
            paidUnpaidButton.imageView?.tintColor = ColorsHelper.laurelGreen
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 32)
            let image = UIImage(systemName: "checkmark.seal", withConfiguration: config)
            paidUnpaidButton.setImage(image, for: .normal)
            paidUnpaidButton.imageView?.tintColor = ColorsHelper.orangeRedCrayola
        }
    }
    
    // MARK: - IBAction
    @IBAction func billPaidButtonTapped(_ sender: Any) {
        delegate?.toggleHasBeenPaid(for: self)
    }
}
