//
//  ExpensesViewController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/4/21.
//

import UIKit
import Charts

class ExpensesViewController: UIViewController, ChartViewDelegate {
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    
    // MARK: - Properties
    let userController = UserController.shared
    let players = ["Clay", "Bronson", "Kim", "Coco", "Jorah", "Lenny"]
    let goals = [6, 8, 26, 30, 8, 10]
    var popUpWindow: PopUpWindow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        userController.loadExpenseData()
        customizeChart(dataPoints:userController.userExpenses)
    }
    
    // MARK: - IBAction
    @IBAction func addButtonTapped(_ sender: Any) {
        popUpWindow = PopUpWindow(title: "Add an expense", text: "Try adding one here", buttontext: "Save")
        self.present(popUpWindow, animated: true)
        
//        let ac = UIAlertController(title: "Add a new Expense", message: nil , preferredStyle: .alert)
//        ac.addTextField { (textField) in
//            textField.placeholder = "Expense Name"
//        }
//        ac.addTextField { (textField) in
//            textField.placeholder = "Dollar Amount"
//        }
//        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
//            let firstTextField = ac.textFields![0]
//            let secondTextField = ac.textFields![1]
//            guard let name = firstTextField.text else { return }
//            guard let dollarAmount = secondTextField.text else { return }
//            self.userController.createExpense(name: name, dollarAmount: Double(dollarAmount)!)
//            self.tableView.reloadData()
//            self.customizeChart(dataPoints: self.userController.userExpenses)
//        }
//        ac.addAction(submitAction)
//        self.present(ac, animated: true, completion: nil)
    }
    
    // MARK: - Methods
    func customizeChart(dataPoints: [Expense]) {
        var dataEntries: [ChartDataEntry] = []
        // MARK: - TODO
        // Change Data Entry to reflect categories along with a percentage of how much 
        for i in 0..<userController.userExpenses.count {
            let expense = dataPoints[i]
            let dataEntry = PieChartDataEntry(value: expense.dollarAmount, label: expense.name)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(entries: dataEntries)
        pieChartDataSet.colors = ChartColorTemplates.colorful()
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
       
        pieChartView.data = pieChartData
    }
    
    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        var colors: [UIColor] = []
        for _ in 0..<numbersOfColor {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        return colors
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let expense = userController.userExpenses[indexPath.row]
            userController.deleteExpenseData(expense: expense)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.customizeChart(dataPoints: userController.userExpenses)
        }
    }
    
}
