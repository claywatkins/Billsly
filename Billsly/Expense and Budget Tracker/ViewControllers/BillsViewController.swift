//
//  BillsViewController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/4/21.
//

import UIKit
import UserNotifications

class BillsViewController: UIViewController {
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var userController = UserController.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        tableView.dataSource = self
        tableView.delegate = self
        userController.loadBillData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Methods
    private func configureView() {
        tableView.backgroundColor = ColorsHelper.blackCoral
        view.backgroundColor = ColorsHelper.blackCoral
        navigationController?.navigationBar.backgroundColor = ColorsHelper.blackCoral
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ColorsHelper.cultured]
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ColorsHelper.cultured]
        navigationController?.navigationBar.barTintColor = ColorsHelper.blackCoral
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func billFor(indexPath: IndexPath) -> Bill {
        if indexPath.section == 0{
            return userController.unpaidBills[indexPath.row]
        } else {
            return userController.paidBills[indexPath.row]
        }
    }

    // MARK: - IBAction
    @IBAction func homeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UpdateBillSegue"{
            if let detailVC = segue.destination as? EditBillViewController,
               let indexPath = tableView.indexPathForSelectedRow {
                let bill = billFor(indexPath: indexPath)
                detailVC.bill = bill
            }
        }
    }
}

extension BillsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if section == 0{
            rows = userController.unpaidBills.count
        } else {
            rows = userController.paidBills.count
        }
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillCell") as? BillTableViewCell else { return UITableViewCell()}
        cell.delegate = self
        let bill = billFor(indexPath: indexPath)
        cell.bill = bill
        cell.contentView.backgroundColor = ColorsHelper.slateGray
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            guard userController.unpaidBills.count > 0 else { return nil }
            return "Unpaid Bills"
        } else {
            guard userController.paidBills.count > 0 else { return nil }
            return "Paid Bills"
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
