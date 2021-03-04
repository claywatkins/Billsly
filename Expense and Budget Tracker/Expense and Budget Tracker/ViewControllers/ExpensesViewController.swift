//
//  ExpensesViewController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/4/21.
//

import UIKit

class ExpensesViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    let userController = UserController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        userController.loadExpenseData()
    }
    
    // MARK: - IBAction
    @IBAction func addButtonTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Add a new Expense", message: nil , preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.placeholder = "Expense Name"
        }
        ac.addTextField { (textField) in
            textField.placeholder = "Dollar Amount"
        }
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            let firstTextField = ac.textFields![0]
            let secondTextField = ac.textFields![1]
            guard let name = firstTextField.text else { return }
            guard let dollarAmount = secondTextField.text else { return }
            self.userController.createExpense(name: name, dollarAmount: Double(dollarAmount)!)
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

extension ExpensesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userController.userExpenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell") else { return UITableViewCell()}
        let expense = userController.userExpenses[indexPath.row]
        cell.textLabel?.text = expense.name
        return cell
    }
    
    
}
