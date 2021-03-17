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
        pieChartView.delegate = self
        displayDate()
        setupCalendar()
        print("Bills Count: \(userController.userBills.count)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fsCalendarView.reloadData()
        billsPaidThisMonth()
        setPieChart(dataPoints: userController.userBills)
    }
    
    // MARK: - Methods
    private func displayDate() {
        userController.df.dateFormat = "EEEE, MMM d, yyyy"
        dateLabel.text = userController.df.string(from: Date())
    }
    
    private func setupCalendar() {
        if self.traitCollection.userInterfaceStyle == .dark {
            fsCalendarView.appearance.titlePlaceholderColor = .white
        }
        fsCalendarView.placeholderType = .none
        fsCalendarView.isUserInteractionEnabled = false
        fsCalendarView.appearance.todayColor = .systemTeal
        fsCalendarView.register(FSCalendarCell.self, forCellReuseIdentifier: "calendarCell")
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
        pieChartDataSet.sliceSpace = 2
        pieChartDataSet.colors = ChartColorTemplates.vordiplom()
            + ChartColorTemplates.joyful()
            + ChartColorTemplates.colorful()
            + ChartColorTemplates.liberty()
            + ChartColorTemplates.pastel()
            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        
        pieChartDataSet.valueLinePart1OffsetPercentage = 0.8
        pieChartDataSet.valueLinePart1Length = 0.2
        pieChartDataSet.valueLinePart2Length = 0.8
        pieChartDataSet.yValuePosition = .outsideSlice
        
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
        pieChartView.legend.enabled = false
//        pieChartView.legend.horizontalAlignment = .right
//        pieChartView.legend.verticalAlignment = .top
//        pieChartView.legend.orientation = .vertical
//        pieChartView.legend.xEntrySpace = 7
//        pieChartView.legend.yEntrySpace = 0
//        pieChartView.legend.yOffset = 0
        pieChartView.highlightPerTapEnabled = false
        pieChartView.animate(xAxisDuration: 1.3, yAxisDuration: 1.3)
        
        pieChartView.data = pieChartData
        
    }
    
    // MARK: - IBActions
    @IBAction func paidBillsButtonTapped(_ sender: Any) {
        if userController.userBills.isEmpty {
            let ac = UIAlertController(title: "No Bills Found", message: "You've got no bills to pay yet! Go on and add some first.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Sounds Good", style: .default, handler: nil))
            self.present(ac, animated: true)
        }
        let popoverContentController = self.storyboard?.instantiateViewController(withIdentifier: "BillPaidPopoverViewController") as? BillPaidPopoverViewController
        popoverContentController?.modalPresentationStyle = .popover
        popoverContentController?.delegate = self
        
        if let popoverPresentationController = popoverContentController?.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(origin: self.calendarHostView.center, size: .zero)
            popoverPresentationController.delegate = self
            if let popoverController = popoverContentController {
                present(popoverController, animated: true, completion: nil)
            }
        }
    }
    
}

// MARK: - Extension
extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        userController.df.dateFormat = "d"
        let dateStr = userController.df.string(from: date)
        if userController.dueByDateStrings.contains(dateStr) {
            return ""
        }
        return userController.df.string(from: date)
    }
    
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        userController.df.dateFormat = "dd"
        let dateStr = userController.df.string(from: date)
        if userController.dueByDateAndPaid.contains(dateStr) && userController.dueByDateAndUnpaid.contains(dateStr) {
            return UIImage(systemName: "dollarsign.circle.fill")
        } else if userController.dueByDateAndPaid.contains(dateStr) {
            return UIImage(systemName: "checkmark.seal.fill")
        } else if userController.dueByDateAndUnpaid.contains(dateStr) {
            return UIImage(systemName: "dollarsign.circle.fill")
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "calendarCell", for: date, at: position)
        userController.df.dateFormat = "dd"
        let dateStr = userController.df.string(from: date)
        if userController.dueByDateAndPaid.contains(dateStr) {
            cell.imageView.tintColor = .systemGreen
        } else if userController.dueByDateAndUnpaid.contains(dateStr) {
            cell.imageView.tintColor = .systemRed
        }
        cell.imageView.contentMode = .scaleAspectFit
        return cell
    }
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        for bill in userController.userBills {
            userController.updateBillToUnpaid(bill: bill)
        }
        billsPaidThisMonth()
        
        for bill in userController.userBills {
            userController.df.dateFormat = "dd"
            let dateNum = Int(userController.df.string(from: bill.dueByDate))!
            if dateNum < 30 && calendar.currentPage.month != "March"{
                var dateComponent = DateComponents()
                dateComponent.month = 1
                let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                userController.updateBillData(bill: bill,
                                              name: bill.name,
                                              dollarAmount: bill.dollarAmount,
                                              dueByDate: moveForwardOneMonth,
                                              category: bill.category)
                calendar.reloadData()
            }
        }
        
        if calendar.currentPage.daysInMonth() == 30 {
            for bill in userController.userBills {
                userController.df.dateFormat = "dd"
                let dateStr = userController.df.string(from: bill.dueByDate)
                if dateStr == "31" {
                    var dateComponent = DateComponents()
                    dateComponent.month = 1
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    calendar.reloadData()
                }
            }
        }
        if calendar.currentPage.daysInMonth() == 31{
            for bill in userController.userBills {
                userController.df.dateFormat = "dd"
                let dateStr = userController.df.string(from: bill.dueByDate)
                if dateStr == "30" {
                    var dateComponent = DateComponents()
                    dateComponent.month = 1
                    if calendar.currentPage.daysInMonth() != calendar.currentPage.daysInMonth(-1){
                        dateComponent.day = 1
                    }
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    calendar.reloadData()
                }
            }
        }
        if calendar.currentPage.month == "August" {
            for bill in userController.userBills {
                userController.df.dateFormat = "dd"
                let dateStr = userController.df.string(from: bill.dueByDate)
                if dateStr == "31" {
                    var dateComponent = DateComponents()
                    dateComponent.month = 1
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    calendar.reloadData()
                }
            }
        }
        if calendar.currentPage.month == "January" {
            for bill in userController.userBills {
                userController.df.dateFormat = "dd"
                let dateStr = userController.df.string(from: bill.dueByDate)
                if dateStr == "31" {
                    var dateComponent = DateComponents()
                    dateComponent.month = 1
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    calendar.reloadData()
                }
            }
        }
        if calendar.currentPage.month == "February" {
            for bill in userController.userBills {
                userController.df.dateFormat = "dd"
                let dateStr = userController.df.string(from: bill.dueByDate)
                if dateStr == "31" {
                    var dateComponent = DateComponents()
                    dateComponent.month = 1
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    calendar.reloadData()
                }
            }
        }
        if calendar.currentPage.month == "March" {
            for bill in userController.userBills {
                userController.df.dateFormat = "dd"
                let dateStr = userController.df.string(from: bill.dueByDate)
                let dateNum = Int(dateStr)!
                if dateNum < 28 {
                    var dateComponent = DateComponents()
                    dateComponent.month = 1
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    calendar.reloadData()
                } else if dateNum == 28 {
                    var dateComponent = DateComponents()
                    dateComponent.month = 1
                    dateComponent.day = 3
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    calendar.reloadData()
                } else if dateStr == "29" {
                    var dateComponent = DateComponents()
                    dateComponent.month = 1
                    dateComponent.day = 2
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    calendar.reloadData()
                }
                
            }
        }
        
    }
}

extension HomeViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension HomeViewController: BillHasBeenPaid {
    func updateCalendar() {
        fsCalendarView.reloadData()
        billsPaidThisMonth()
    }
}

extension HomeViewController: ChartViewDelegate {
    
}
