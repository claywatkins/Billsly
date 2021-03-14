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
        setupCalendar()
        print("Bills Count: \(userController.userBills.count)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fsCalendarView.reloadData()
        billsPaidThisMonth()
    }
    
    // MARK: - Methods
    private func displayDate() {
        userController.df.dateFormat = "EEEE, MMM d, yyyy"
        dateLabel.text = userController.df.string(from: Date())
    }
    
    private func setupCalendar() {
        fsCalendarView.isUserInteractionEnabled = false
        fsCalendarView.appearance.todayColor = .systemTeal
        fsCalendarView.register(FSCalendarCell.self, forCellReuseIdentifier: "calendarCell")
    }
    
    private func billsPaidThisMonth() {
        let billsPaid = userController.paidBills.count
        let totalBills = userController.userBills.count
        amountOfBillsPaid.text = "You have \(totalBills - billsPaid) bills left to pay this month."
    }
    
    // MARK: - IBActions
    @IBAction func paidBillsButtonTapped(_ sender: Any) {
        let popoverContentController = self.storyboard?.instantiateViewController(withIdentifier: "BillPaidPopoverViewController") as? BillPaidPopoverViewController
        popoverContentController?.modalPresentationStyle = .popover
        
        if let popoverPresentationController = popoverContentController?.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .any
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(origin: self.view.center, size: .zero)
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
        userController.df.dateFormat = "EEEE, MMM d, yyyy"
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
        userController.df.dateFormat = "EEEE, MMM d, yyyy"
        let dateStr = userController.df.string(from: date)
        if userController.dueByDateAndPaid.contains(dateStr) {
            cell.imageView.tintColor = .systemGreen
        } else if userController.dueByDateAndUnpaid.contains(dateStr) {
            cell.imageView.tintColor = .systemRed
        }
        cell.imageView.contentMode = .scaleAspectFit
        return cell
    }
}

extension HomeViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

