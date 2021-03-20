//
//  HomeViewController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/11/21.
//

import UIKit
import FSCalendar

class HomeViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var amountOfBillsPaid: UILabel!
    @IBOutlet weak var calendarHostView: UIView!
    @IBOutlet weak var fsCalendarView: FSCalendar!
    @IBOutlet weak var progressHostView: UIView!
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var paidBillButton: UIButton!
    @IBOutlet weak var manageBillsButton: UIButton!
    @IBOutlet weak var paidThisMonthLabel: UILabel!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak var previousMonthButton: UIButton!
    
    // MARK: - Properties
    let userController = UserController.shared
    let shapeLayer = CAShapeLayer()
    var displayLink: CADisplayLink?
    var animationStartTime = Date()
    let duration: Double = 2
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = ColorsHelper.bone
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        userController.loadBillData()
        userController.loadCategoryData()
        displayDate()
        configureViews()
        constructProgressCircle()
        print("Bills Count: \(userController.userBills.count)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fsCalendarView.reloadData()
        billsPaidThisMonth()
        setupCalendar()
        animateStrokeProgressCircle(to: userController.calculatedBillProgressFloat)
        animationStartTime = Date()
    }
    
    // MARK: - Methods
    private func configureViews() {
        view.backgroundColor = ColorsHelper.blackCoral
        userNameLabel.textColor = ColorsHelper.bone
        dateLabel.textColor = ColorsHelper.cultured
        amountOfBillsPaid.textColor = ColorsHelper.bone
        userView.configureView(ColorsHelper.slateGray)
        calendarHostView.configureView(ColorsHelper.slateGray)
        progressBarView.configureView(ColorsHelper.slateGray)
        paidBillButton.configureButton(ColorsHelper.grullo)
        manageBillsButton.configureButton(ColorsHelper.grullo)
        nextMonthButton.configureButton(ColorsHelper.grullo)
        previousMonthButton.configureButton(ColorsHelper.grullo)
        settingsButton.backgroundColor = UIColor.clear
        settingsButton.tintColor = ColorsHelper.bone
        paidThisMonthLabel.textColor = ColorsHelper.bone
    }
    
    private func displayDate() {
        userController.df.dateFormat = "EEEE, MMM d, yyyy"
        dateLabel.text = "Today is " + userController.df.string(from: Date())
    }
    
    private func setupCalendar() {
        fsCalendarView.placeholderType = .none
        fsCalendarView.isUserInteractionEnabled = false
        fsCalendarView.layer.cornerRadius = 12
        fsCalendarView.backgroundColor = ColorsHelper.independence
        fsCalendarView.appearance.weekdayTextColor = ColorsHelper.powderBlue
        fsCalendarView.appearance.headerTitleColor = ColorsHelper.powderBlue
        fsCalendarView.calendarHeaderView.tintColor = ColorsHelper.powderBlue
        userController.df.dateFormat = "d"
        let todayStr = userController.df.string(from: fsCalendarView.today!)
        if userController.dueByDateStrings.contains(todayStr) {
            fsCalendarView.appearance.todayColor = .clear
        } else {
            fsCalendarView.appearance.todayColor = .systemTeal
        }
        fsCalendarView.register(FSCalendarCell.self, forCellReuseIdentifier: "calendarCell")
    }
    
    private func billsPaidThisMonth() {
        let billsPaid = userController.paidBills.count
        let totalBills = userController.userBills.count
        if totalBills == 0 {
            amountOfBillsPaid.text = "No bills added yet. Add some bills to track your progress!"
        }
        amountOfBillsPaid.text = "You have \(totalBills - billsPaid) bills left to pay this month."
        paidThisMonthLabel.text = "You have spent \(userController.amountSpentOnBills) on bills this month!"
    }
    
    private func constructProgressCircle() {
        progressBarView.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0,
                                       y: 0,
                                       width: 200,
                                       height: 100)
        percentageLabel.center = progressBarView.center
        let center = progressBarView.center
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: 90,
                                        startAngle: -CGFloat.pi/2,
                                        endAngle: 3*CGFloat.pi/2,
                                        clockwise: true)
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 12
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        progressBarView.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = ColorsHelper.orangeRedCrayola.cgColor
        shapeLayer.borderWidth = 2
        shapeLayer.borderColor = ColorsHelper.apricot.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.strokeEnd = 0
        progressBarView.layer.addSublayer(shapeLayer)
    }
    private func animateStrokeProgressCircle(to float: CGFloat) {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = float
        basicAnimation.duration = duration
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        shapeLayer.add(basicAnimation, forKey: "basic")
        animateLabel()
    }
    
    private func animateLabel() {
        displayLink = CADisplayLink(target: self,
                                    selector: #selector(handleUpdate))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    @objc private func handleUpdate() {
        let now = Date()
        let elapsedTime = now.timeIntervalSince(animationStartTime)
        if elapsedTime > duration {
            self.percentageLabel.text = userController.calculatedBillProgressString + "\n of bills paid!"
            if userController.calculatedBillProgressFloat == 1{
                percentageLabel.text = userController.calculatedBillProgressString + "\n All bills paid 😎"
            }
        } else {
            let pFormatter = NumberFormatter()
            pFormatter.numberStyle = .percent
            pFormatter.percentSymbol = "%"
            let percentage = elapsedTime / duration
            let value = 0.0 + CGFloat(percentage) * (userController.calculatedBillProgressFloat - 0.0) as NSNumber
            self.percentageLabel.text = pFormatter.string(from: value)! + "\n of bills paid!"
        }
    }
    
    private func moveToNextMonth() {
        let currentDate = fsCalendarView.currentPage
        var dateComponents = DateComponents()
        dateComponents.month = 1
        let nextMonth = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        fsCalendarView.setCurrentPage(nextMonth!, animated: true)
    }
    
    private func moveToPerviousMonth() {
        let currentDate = fsCalendarView.currentPage
        var dateComponents = DateComponents()
        dateComponents.month = -1
        let prevMonth = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        fsCalendarView.setCurrentPage(prevMonth!, animated: true)
    }
    
    // MARK: - IBActions
    @IBAction func paidBillsButtonTapped(_ sender: Any) {
        if userController.userBills.isEmpty {
            let ac = UIAlertController(title: "No Bills Found", message: "You've got no bills to pay yet! Go on and add some first.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Sounds Good", style: .default, handler: nil))
            self.present(ac, animated: true)
        } else if userController.unpaidBills.isEmpty {
            let ac = UIAlertController(title: "All Bills Paid", message: "You've paid all your bills for the month!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Hooray!", style: .default, handler: nil))
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
    @IBAction func nextMonthButtonTapped(_ sender: Any) {
        moveToNextMonth()
        for bill in userController.userBills {
            userController.updateBillToUnpaid(bill: bill)
        }
        billsPaidThisMonth()
        
        for bill in userController.userBills {
            userController.df.dateFormat = "dd"
            let dateNum = Int(userController.df.string(from: bill.dueByDate))!
            if dateNum < 30 && fsCalendarView.currentPage.month != "March"{
                var dateComponent = DateComponents()
                dateComponent.month = 1
                let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                userController.updateBillData(bill: bill,
                                              name: bill.name,
                                              dollarAmount: bill.dollarAmount,
                                              dueByDate: moveForwardOneMonth,
                                              category: bill.category)
                fsCalendarView.reloadData()
            }
        }
        
        if fsCalendarView.currentPage.daysInMonth() == 30 {
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
                    fsCalendarView.reloadData()
                }
            }
        }
        if fsCalendarView.currentPage.daysInMonth() == 31{
            for bill in userController.userBills {
                userController.df.dateFormat = "dd"
                let dateStr = userController.df.string(from: bill.dueByDate)
                if dateStr == "30" {
                    var dateComponent = DateComponents()
                    dateComponent.month = 1
                    if fsCalendarView.currentPage.daysInMonth() != fsCalendarView.currentPage.daysInMonth(-1){
                        dateComponent.day = 1
                    }
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    fsCalendarView.reloadData()
                }
            }
        }
        if fsCalendarView.currentPage.month == "August" {
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
                    fsCalendarView.reloadData()
                }
            }
        }
        if fsCalendarView.currentPage.month == "January" {
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
                    fsCalendarView.reloadData()
                }
            }
        }
        if fsCalendarView.currentPage.month == "February" {
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
                    fsCalendarView.reloadData()
                }
            }
        }
        if fsCalendarView.currentPage.month == "March" {
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
                    fsCalendarView.reloadData()
                } else if dateNum == 28 {
                    var dateComponent = DateComponents()
                    dateComponent.month = 1
                    dateComponent.day = 3
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    fsCalendarView.reloadData()
                } else if dateStr == "29" {
                    var dateComponent = DateComponents()
                    dateComponent.month = 1
                    dateComponent.day = 2
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    fsCalendarView.reloadData()
                }
                
            }
        }
    }
    @IBAction func previousMonthButtonTapped(_ sender: Any) {
        moveToPerviousMonth()
        billsPaidThisMonth()
        for bill in userController.userBills {
            userController.updateBillToUnpaid(bill: bill)
        }
    
        for bill in userController.userBills {
            userController.df.dateFormat = "dd"
            let dateNum = Int(userController.df.string(from: bill.dueByDate))!
            if dateNum < 30 && fsCalendarView.currentPage.month != "Febuary"{
                var dateComponent = DateComponents()
                dateComponent.month = -1
                let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                userController.updateBillData(bill: bill,
                                              name: bill.name,
                                              dollarAmount: bill.dollarAmount,
                                              dueByDate: moveForwardOneMonth,
                                              category: bill.category)
                fsCalendarView.reloadData()
            }
        }
        
        if fsCalendarView.currentPage.daysInMonth() == 30 {
            for bill in userController.userBills {
                userController.df.dateFormat = "dd"
                let dateStr = userController.df.string(from: bill.dueByDate)
                if dateStr == "31" {
                    var dateComponent = DateComponents()
                    dateComponent.month = -1
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    fsCalendarView.reloadData()
                }
            }
        }
        if fsCalendarView.currentPage.daysInMonth() == 31{
            for bill in userController.userBills {
                userController.df.dateFormat = "dd"
                let dateStr = userController.df.string(from: bill.dueByDate)
                if dateStr == "30" {
                    var dateComponent = DateComponents()
                    dateComponent.month = -1
                    if fsCalendarView.currentPage.daysInMonth() != fsCalendarView.currentPage.daysInMonth(-1){
                        dateComponent.day = -1
                    }
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    fsCalendarView.reloadData()
                }
            }
        }
        if fsCalendarView.currentPage.month == "July" {
            for bill in userController.userBills {
                userController.df.dateFormat = "dd"
                let dateStr = userController.df.string(from: bill.dueByDate)
                if dateStr == "31" {
                    var dateComponent = DateComponents()
                    dateComponent.month = -1
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    fsCalendarView.reloadData()
                }
            }
        }
        if fsCalendarView.currentPage.month == "December" {
            for bill in userController.userBills {
                userController.df.dateFormat = "dd"
                let dateStr = userController.df.string(from: bill.dueByDate)
                if dateStr == "31" {
                    var dateComponent = DateComponents()
                    dateComponent.month = -1
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    fsCalendarView.reloadData()
                }
            }
        }
        if fsCalendarView.currentPage.month == "January" {
            for bill in userController.userBills {
                userController.df.dateFormat = "dd"
                let dateStr = userController.df.string(from: bill.dueByDate)
                if dateStr == "31" {
                    var dateComponent = DateComponents()
                    dateComponent.month = -1
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    fsCalendarView.reloadData()
                }
            }
        }
        if fsCalendarView.currentPage.month == "Febuary" {
            for bill in userController.userBills {
                userController.df.dateFormat = "dd"
                let dateStr = userController.df.string(from: bill.dueByDate)
                let dateNum = Int(dateStr)!
                if dateNum < 28 {
                    var dateComponent = DateComponents()
                    dateComponent.month = -1
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    fsCalendarView.reloadData()
                } else if dateNum == 28 {
                    var dateComponent = DateComponents()
                    dateComponent.month = -1
                    dateComponent.day = -3
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    fsCalendarView.reloadData()
                } else if dateStr == "29" {
                    var dateComponent = DateComponents()
                    dateComponent.month = -1
                    dateComponent.day = -2
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponent, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth, category: bill.category)
                    fsCalendarView.reloadData()
                }
                
            }
        }
    }
    
}

// MARK: - Extension
extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return ColorsHelper.cultured
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        return ColorsHelper.cultured
    }
    
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
            cell.imageView.tintColor = ColorsHelper.laurelGreen
        } else if userController.dueByDateAndUnpaid.contains(dateStr) {
            cell.imageView.tintColor = ColorsHelper.orangeRedCrayola
        }
        cell.imageView.contentMode = .scaleAspectFill
        return cell
    }
}

extension HomeViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension HomeViewController: BillHasBeenPaid {
    func updateCalendar() {
        animationStartTime = Date()
        fsCalendarView.reloadData()
        billsPaidThisMonth()
        animateStrokeProgressCircle(to: userController.calculatedBillProgressFloat)
    }
}
