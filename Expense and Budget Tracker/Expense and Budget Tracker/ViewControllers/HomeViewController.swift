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
    let userController = UserController.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        userController.loadBillData()
        userController.loadCategoryData()
        displayDate()
        billsPaidThisMonth()
        print("Bills Count: \(userController.userBills.count)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        billsPaidThisMonth()
    }
    
    // MARK: - Methods
    private func displayDate() {
        userController.df.dateFormat = "EEEE, MMM d, yyyy"
        dateLabel.text = userController.df.string(from: Date())
    }
    
    private func billsPaidThisMonth() {
        let billsPaid = userController.paidBills.count
        let totalBills = userController.userBills.count
        amountOfBillsPaid.text = "You have \(totalBills - billsPaid) bills left to pay this month."
    }
    
    // MARK: - IBActions
    @IBAction func paidBillsButtonTapped(_ sender: Any) {
        
    }
    
}

// MARK: - Extension
extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        userController.df.dateFormat = "EEEE, MMM d, yyyy"
        var dateArray: [String] = []
        let dateStr = userController.df.string(from: date)
        for bill in userController.userBills {
            let dateStr = userController.df.string(from: bill.dueByDate)
            dateArray.append(dateStr)
        }
        
        cell.eventIndicator.isHidden = false
        cell.eventIndicator.color = UIColor.blue
        
        if dateArray.contains(dateStr) {
            cell.eventIndicator.numberOfEvents = 1
        }
    }
}



