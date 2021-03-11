//
//  HomeViewController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/11/21.
//

import UIKit
import FSCalendar
import Charts

class HomeViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountOfBillsPaid: UILabel!
    @IBOutlet weak var calendarHostView: UIView!
    @IBOutlet weak var fsCalendarView: FSCalendar!
    @IBOutlet weak var chartHostView: UIView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var paidBillButton: UIButton!
    @IBOutlet weak var manageBillsButton: UIButton!
    
    
    // MARK: - Properties
    let df = DateFormatter()
    let userController = UserController.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        displayDate()
        billsPaidThisMonth()
    }
    
    // MARK: - Methods
    private func displayDate() {
        df.dateFormat = "EEEE, MMM d, yyyy"
        dateLabel.text = df.string(from: Date())
    }
    
    private func billsPaidThisMonth() {
        let billsPaid = userController.paidBills.count
        let totalBills = userController.userBills.count
        amountOfBillsPaid.text = "You have paid \(billsPaid) of \(totalBills) bills this month."
    }
    
    // MARK: - IBActions
    @IBAction func paidBillsButtonTapped(_ sender: Any) {
        
    }
    
}
