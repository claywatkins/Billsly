//
//  HomeViewController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/11/21.
//

import UIKit
import FSCalendar
import UserNotifications
import SwiftConfettiView

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
    
    // MARK: - Properties
    var userController = UserController.shared
    let shapeLayer = CAShapeLayer()
    var displayLink: CADisplayLink?
    var animationStartTime = Date()
    let duration: Double = 2
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = ColorsHelper.cultured
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        userController.loadBillData()
        userController.loadCategoryData()
        displayDate()
        constructProgressCircle()
        checkDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fsCalendarView.reloadData()
        displayUsername()
        billsPaidThisMonth()
        setupCalendar()
        animateViewsIfEnabled()
        checkCurrentMonth()
        scheduleNotifications()
        animateStrokeProgressCircle(to: userController.calculatedBillProgressFloat)
        animationStartTime = Date()
        updateUIAppearence()
    }
    
    // MARK: - Methods
    private func updateUIAppearence() {
        let defaults = UserDefaults.standard
        let selection = defaults.integer(forKey: "appearanceSelection")
        switch selection {
        case 0:
            configureViews()
        case 1:
            overrideUserInterfaceStyle = .dark
        case 2:
            overrideUserInterfaceStyle = .light
        case 3:
            overrideUserInterfaceStyle = .unspecified
        default:
            print("Error")
            break
        }
    }
    
    private func configureViews() {
        view.backgroundColor = ColorsHelper.blackCoral
        userNameLabel.textColor = ColorsHelper.cultured
        dateLabel.textColor = ColorsHelper.cultured
        amountOfBillsPaid.textColor = ColorsHelper.cultured
        userView.configureView(ColorsHelper.slateGray)
        calendarHostView.configureView(ColorsHelper.slateGray)
        progressBarView.configureView(ColorsHelper.slateGray)
        paidBillButton.configureButton(ColorsHelper.slateGray)
        manageBillsButton.configureButton(ColorsHelper.slateGray)
        settingsButton.tintColor = ColorsHelper.cultured
        paidThisMonthLabel.textColor = ColorsHelper.cultured
    }
    
    private func confettiRain() {
        let confettiView = SwiftConfettiView(frame: self.view.bounds)
        confettiView.colors = [ColorsHelper.orangeRedCrayola, ColorsHelper.laurelGreen, ColorsHelper.yellow]
        confettiView.intensity = 0.7
        confettiView.isUserInteractionEnabled = false
        view.addSubview(confettiView)
        confettiView.startConfetti()
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
            confettiView.stopConfetti()
        }
    }
    
    private func animateViewsIfEnabled() {
        if UserDefaults.standard.bool(forKey: "animationsEnabled") {
            let views = [userView, calendarHostView, progressBarView]
            let viewControllerHeight = self.view.bounds.size.height
            for view in views{
                view!.transform = CGAffineTransform(translationX: 0, y: viewControllerHeight)
            }
            var delayCounter = 0
            for view in views {
                UIView.animate(withDuration: 1.75, delay: Double(delayCounter) * 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    view!.transform = CGAffineTransform.identity
                }, completion: nil)
                delayCounter += 1
            }
        }
    }
    
    private func displayDate() {
        userController.df.dateFormat = "EEEE, MMM d, yyyy"
        dateLabel.text = "Today is " + userController.df.string(from: Date())
    }
    
    private func displayUsername() {
        if let username = UserDefaults.standard.string(forKey: "username") {
            userNameLabel.text = "Welcome back, " + username
        } else {
            userNameLabel.text = "Welcome to Billsly!"
        }
    }
    
    private func checkDefaults() {
        if UserDefaults.standard.string(forKey: "currentMonth") == nil {
            UserDefaults.standard.setValue(fsCalendarView.currentPage.month, forKey: "currentMonth")
        }
        if UserDefaults.standard.value(forKey: "animationsEnabled") == nil{
            UserDefaults.standard.setValue(true, forKey: "animationsEnabled")
        }
        if UserDefaults.standard.value(forKey: "ShowAlert") == nil {
            UserDefaults.standard.setValue(true, forKey: "ShowAlert")
        }
        if UserDefaults.standard.value(forKey: "firstTimeUser") == nil {
            UserDefaults.standard.setValue(false, forKey: "firstTimeUser")
            let ac = UIAlertController(title: "Welcome to Billsly", message: "Thanks for downloading Billsly, my very first iOS App! Head on over to settings to add your name for a personal touch, or jump straight in and start adding your bills. \n\n Thank you for using Billsly!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Thanks!", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(ac, animated: true)
                self.askForUserAuthNotifications()
            }
        }
    }
    
    private func checkCurrentMonth() {
        if UserDefaults.standard.string(forKey: "currentMonth") != nil && UserDefaults.standard.string(forKey: "currentMonth") != fsCalendarView.currentPage.month {
            UserDefaults.standard.setValue(fsCalendarView.currentPage.month, forKey: "currentMonth")
            moveBillsToNextMonth()
        }
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
            fsCalendarView.appearance.todayColor = ColorsHelper.celadonGreen
        }
        fsCalendarView.register(FSCalendarCell.self, forCellReuseIdentifier: "calendarCell")
    }
    
    private func billsPaidThisMonth() {
        let billsPaid = userController.paidBills.count
        let totalBills = userController.userBills.count
        let totalUnpaidBills = userController.unpaidBills.count
        if totalBills == 0 {
            amountOfBillsPaid.text = "No bills added yet. Add some bills to track your progress!"
            paidThisMonthLabel.text = ""
        } else if totalUnpaidBills == 1 {
            amountOfBillsPaid.text = "You have 1 bill left to pay this month"
            paidThisMonthLabel.text = "You have spent \(userController.amountSpentOnBills) on bills!"
        } else if billsPaid == totalBills{
            amountOfBillsPaid.text = "All bills are paid for this month!"
            paidThisMonthLabel.text = "You have spent \(userController.amountSpentOnBills) on bills!"
            
        } else {
            amountOfBillsPaid.text = "You have \(totalBills - billsPaid) bills left to pay this month."
            paidThisMonthLabel.text = "You have spent \(userController.amountSpentOnBills) on bills!"
        }
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
        switch float {
        case 0...0.49:
            shapeLayer.strokeColor = ColorsHelper.orangeRedCrayola.cgColor
        case 0.5...0.99:
            shapeLayer.strokeColor = ColorsHelper.yellow.cgColor
        case 1:
            shapeLayer.strokeColor = ColorsHelper.laurelGreen.cgColor
        default:
            shapeLayer.strokeColor = ColorsHelper.orangeRedCrayola.cgColor
        }
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
            if userController.calculatedBillProgressFloat == 1{
                percentageLabel.text = userController.calculatedBillProgressString + "\n All bills paid 😎"
            }
        } else {
            let pFormatter = NumberFormatter()
            pFormatter.numberStyle = .percent
            pFormatter.percentSymbol = "%"
            let percentage = elapsedTime / duration
            let value = 0.0 + CGFloat(percentage) * (userController.calculatedBillProgressFloat - 0.0) as NSNumber
            if Float(truncating: value).isNaN{
                self.percentageLabel.text = "0% \n of bills paid"
            } else {
                self.percentageLabel.text = pFormatter.string(from: value)! + "\n of bills paid"
            }
        }
    }
    
    private func askForUserAuthNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            if let error = error {
                NSLog(error.localizedDescription)
            }
        }
    }
    
    private func scheduleNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        for bill in userController.unpaidBills {
            let content = UNMutableNotificationContent()
            content.title = "Upcoming bill due tomorrow"
            content.body = "Don't forget to pay \(bill.name) tomorrow and then mark it as paid in Billsly!"
            content.sound = UNNotificationSound.default
            
            var billDate: Int {
                userController.df.dateFormat = "d"
                return Int(userController.df.string(from: bill.dueByDate))!
            }
            
            var dateComponents = DateComponents()
            if billDate == 1 {
                dateComponents.calendar = Calendar.current
                dateComponents.timeZone = TimeZone.current
                dateComponents.day = billDate
                dateComponents.hour = 11
            } else {
                dateComponents.calendar = Calendar.current
                dateComponents.timeZone = TimeZone.current
                dateComponents.day = billDate - 1
                dateComponents.hour = 11
            }
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: bill.identifier,
                                                content: content,
                                                trigger: trigger)
            center.add(request) { error in
                if let error = error {
                    print("Error creating notification")
                    print("Error: \(error.localizedDescription)")
                }
            }
            center.getPendingNotificationRequests { requests in
                for request in requests {
                    print(request.trigger!)
                }
            }
        }
    }
    
    private func moveBillsToNextMonth() {
        billsPaidThisMonth()
        for bill in userController.paidBills {
            userController.updateBillToUnpaid(bill: bill)
        }
        
        for bill in userController.userBills {
            let dateNum = Int(userController.df.string(from: bill.dueByDate))!
            var dateComponents = DateComponents()
            dateComponents.month = 1
            if dateNum < 30 && fsCalendarView.currentPage.month != "March"{
                let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponents, to: bill.dueByDate)!
                userController.updateBillData(bill: bill,
                                              name: bill.name,
                                              dollarAmount: bill.dollarAmount,
                                              dueByDate: moveForwardOneMonth,
                                              category: bill.category,
                                              isOn30th: bill.isOn30th)
                continue
            }
            
            switch fsCalendarView.currentPage.month {
            case "January", "February", "April", "June", "August", "September", "November":
                dateComponents.month = 1
                let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponents, to: bill.dueByDate)!
                userController.updateBillData(bill: bill,
                                              name: bill.name,
                                              dollarAmount: bill.dollarAmount,
                                              dueByDate: moveForwardOneMonth,
                                              category: bill.category,
                                              isOn30th: bill.isOn30th)
                continue
                
            case "May", "July", "October", "December":
                if bill.isOn30th == true {
                    dateComponents.month = 1
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponents, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth,
                                                  category: bill.category,
                                                  isOn30th: bill.isOn30th)
                    continue
                } else {
                    dateComponents.month = 1
                    dateComponents.day = 1
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponents, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth,
                                                  category: bill.category,
                                                  isOn30th: bill.isOn30th)
                    continue
                }
                
            case "March":
                if dateNum < 28 {
                    dateComponents.month = 1
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponents, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth,
                                                  category: bill.category,
                                                  isOn30th: bill.isOn30th)
                    continue
                } else if dateNum == 28 {
                    if bill.isOn30th == true {
                        dateComponents.day = 2
                    } else {
                        dateComponents.day = 3
                    }
                    dateComponents.month = 1
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponents, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth,
                                                  category: bill.category,
                                                  isOn30th: bill.isOn30th)
                    continue
                } else if dateNum == 29 {
                    if bill.isOn30th == true {
                        dateComponents.day = 1
                    } else {
                        dateComponents.day = 2
                    }
                    let moveForwardOneMonth = Calendar.current.date(byAdding: dateComponents, to: bill.dueByDate)!
                    userController.updateBillData(bill: bill,
                                                  name: bill.name,
                                                  dollarAmount: bill.dollarAmount,
                                                  dueByDate: moveForwardOneMonth,
                                                  category: bill.category,
                                                  isOn30th: bill.isOn30th)
                    continue
                }
                
            default:
                fatalError()
            }
        }
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
            popoverPresentationController.sourceRect = CGRect(origin: CGPoint(x: view.bounds.width/2, y: 200), size:.zero)
            
            popoverPresentationController.delegate = self
            if let popoverController = popoverContentController {
                present(popoverController, animated: true, completion: nil)
            }
        }
    }
}
// MARK: - Extension
extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
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
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        calendar.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "calendarCell", for: date, at: position)
        userController.df.dateFormat = "dd"
        let dateStr = userController.df.string(from: date)
        if userController.dueByDateAndPaid.contains(dateStr) && userController.dueByDateAndUnpaid.contains(dateStr){
            cell.imageView.tintColor = ColorsHelper.yellow
        } else if userController.dueByDateAndPaid.contains(dateStr) {
            cell.imageView.tintColor = ColorsHelper.laurelGreen
        } else  {
            cell.imageView.tintColor = ColorsHelper.orangeRedCrayola
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

extension HomeViewController: BillHasBeenPaid {
    func updateCalendar() {
        animationStartTime = Date()
        fsCalendarView.reloadData()
        billsPaidThisMonth()
        confettiRain()
        animateStrokeProgressCircle(to: userController.calculatedBillProgressFloat)
    }
}
