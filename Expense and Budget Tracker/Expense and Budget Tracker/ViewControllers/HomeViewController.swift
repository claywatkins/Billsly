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
        setPieChart(dataPoints: userController.userBills)
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
    
    private func setPieChart(dataPoints: [Bill]) {
        pieChartView.noDataText = "Add a bill to see the breakdown"
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<userController.userBills.count {
            let bill = dataPoints[i]
            let dataEntry = PieChartDataEntry(value: bill.dollarAmount, label: bill.category.name)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(entries: dataEntries)
        pieChartDataSet.colors = ChartColorTemplates.vordiplom()
        pieChartDataSet.sliceSpace = 2
        
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        pieChartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        pieChartData.setValueFont(.systemFont(ofSize: 14, weight: .medium))
        pieChartData.setValueTextColor(.black)
        
        pieChartView.drawHoleEnabled = false
        pieChartView.usePercentValuesEnabled = true
        pieChartView.legend.horizontalAlignment = .right
        pieChartView.legend.verticalAlignment = .top
        pieChartView.legend.orientation = .vertical
        pieChartView.legend.xEntrySpace = 7
        pieChartView.legend.yEntrySpace = 0
        pieChartView.legend.yOffset = 0
        pieChartView.highlightPerTapEnabled = false
        pieChartView.animate(xAxisDuration: 1.3, yAxisDuration: 1.3)
        
        pieChartView.data = pieChartData
        
    }
    
    // MARK: - IBActions
    @IBAction func paidBillsButtonTapped(_ sender: Any) {
        
    }
    
}
