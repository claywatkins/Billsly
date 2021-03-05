//
//  BillsViewController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/4/21.
//

import UIKit

class BillsViewController: UIViewController {
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    let userController = UserController.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        userController.loadBillData()
    }
    
    // MARK: - Methods
    func billFor(indexPath: IndexPath) -> Bill {
        if indexPath.section == 0{
            return userController.paidBills[indexPath.row]
        } else {
            return userController.unpaidBills[indexPath.row]
        }
    }
    
    // MARK: - IBAction
    @IBAction func addBillTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Add a new Bill", message: nil , preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.placeholder = "Bill Name"
        }
        ac.addTextField { (textField) in
            textField.placeholder = "Dollar Amount"
        }
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            let firstTextField = ac.textFields![0]
            let secondTextField = ac.textFields![1]
            guard let name = firstTextField.text else { return }
            guard let dollarAmount = secondTextField.text else { return }
            self.userController.createBill(name: name, dollarAmount: Double(dollarAmount)!)
            self.tableView.reloadData()
        }
        ac.addAction(submitAction)
        self.present(ac, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }


}

extension BillsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if section == 0{
            rows = userController.paidBills.count
        } else {
            rows = userController.unpaidBills.count
        }
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillCell") as? BillTableViewCell else { return UITableViewCell()}
        cell.delegate = self
        let bill = billFor(indexPath: indexPath)
        cell.bill = bill
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            guard userController.paidBills.count > 0 else { return nil }
            return "Paid Bills"
        } else {
            guard userController.unpaidBills.count > 0 else { return nil }
            return "Unpaid Bills"
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let bill = billFor(indexPath: indexPath)
            userController.deleteBillData(bill: bill)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension BillsViewController: BillTableViewCellDelegate {
    func toggleHasBeenPaid(for cell: BillTableViewCell) {
        guard let selectedBill = tableView.indexPath(for: cell) else { return }
        let bill = billFor(indexPath: selectedBill)
        userController.updateBillHasBeenPaid(bill: bill)
        tableView.reloadData()
    }
}
