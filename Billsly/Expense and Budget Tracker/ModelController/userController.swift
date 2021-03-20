//
//  ExpenseController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/3/21.
//

import UIKit

class UserController {
    
    // MARK: - Properties
    static let shared = UserController()
    let df = DateFormatter()
    let nf = NumberFormatter()
    var userBills: [Bill] = []
    var userCategories: [Category] = []
    var persistentBillsFileURL: URL? {
        let fm = FileManager.default
        guard let documents = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documents.appendingPathComponent("userBills.plist")
    }
    var persistentCategoriesFileURL: URL? {
        let fm = FileManager.default
        guard let documents = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documents.appendingPathComponent("userCategories.plist")
    }
    var paidBills: [Bill] {
        let bills = userBills
        let filteredPaidBills = bills.filter{ (bills) -> Bool in bills.hasBeenPaid == true }
        let sortedBills = filteredPaidBills.sorted(by: {$0.dueByDate < $1.dueByDate})
        return sortedBills
    }
    var unpaidBills: [Bill] {
        let bills = userBills
        let filteredUnpaidBills = bills.filter { (bills) -> Bool in bills.hasBeenPaid == false }
        let sortedBills = filteredUnpaidBills.sorted(by: {$0.dueByDate < $1.dueByDate})
        return sortedBills
    }
    var dueByDateStrings: [String] {
        var dateArray: [String] = []
        for bill in userBills {
            let dateStr = self.df.string(from: bill.dueByDate)
            dateArray.append(dateStr)
        }
        return dateArray
    }
    var dueByDateAndPaid: [String] {
        var dateArray: [String] = []
        for bill in userBills {
            if bill.hasBeenPaid {
                let dateStr = self.df.string(from: bill.dueByDate)
                dateArray.append(dateStr)
            }
        }
        return dateArray
    }
    var dueByDateAndUnpaid: [String] {
        var dateArray: [String] = []
        for bill in userBills {
            if bill.hasBeenPaid == false {
                let dateStr = self.df.string(from: bill.dueByDate)
                dateArray.append(dateStr)
            }
        }
        return dateArray
    }
    var calculatedBillProgressString: String {
        let paidBillsCount = Float(paidBills.count)
        let totalBillsCount = Float(userBills.count)
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = "%"
        let billsPaidPercentage = paidBillsCount/totalBillsCount * 100
        return pFormatter.string(from: NSNumber(value: billsPaidPercentage))!
    }
    var calculatedBillProgressFloat: CGFloat {
        let paidBillsCount = CGFloat(paidBills.count)
        let totalBillsCount = CGFloat(userBills.count)
        return paidBillsCount/totalBillsCount
    }
    
    var amountSpentOnBills: String {
        var count = 0.0
        for bill in paidBills {
            count += bill.dollarAmount
        }
        nf.numberStyle = .currency
        guard let numberStr = nf.string(from: NSNumber(value: count)) else {
            return "$0.00"
        }
        return numberStr
    }
    
    // MARK: - CRUD
    func createBill(name: String, dollarAmount: Double, dueByDate: Date, category: Category) {
        let newBill = Bill(name: name, dollarAmount: dollarAmount, dueByDate: dueByDate, category: category)
        userBills.append(newBill)
        print("Bill Added Successfully")
        saveBillsToPersistentStore()
        
    }
    func createCategory(name: String) {
        let newCategory = Category(name: name)
        userCategories.append(newCategory)
        print("Category saved")
        saveCategoriesToPersistentStore()
    }
    func updateBillHasBeenPaid(bill: Bill) {
        if let billIndex = userBills.firstIndex(of: bill) {
            userBills[billIndex].hasBeenPaid.toggle()
        }
        saveBillsToPersistentStore()
    }
    func updateBillToUnpaid(bill: Bill) {
        if let billIndex = userBills.firstIndex(of: bill) {
            userBills[billIndex].hasBeenPaid = false
        }
        saveBillsToPersistentStore()
    }
    func updateBillData(bill: Bill, name: String, dollarAmount: Double, dueByDate: Date, category: Category) {
        if let bookIndex = userBills.firstIndex(of: bill) {
            userBills[bookIndex].name = name
            userBills[bookIndex].dollarAmount = dollarAmount
            userBills[bookIndex].dueByDate = dueByDate
            userBills[bookIndex].category = category
        }
        saveBillsToPersistentStore()
    }
    func deleteBillData(bill: Bill){
        guard let billIndex = userBills.firstIndex(of: bill) else { return }
        userBills.remove(at: billIndex)
        saveBillsToPersistentStore()
    }
    func deleteCategoryData(category: Category) {
        guard let categoryIndex = userCategories.firstIndex(of: category) else { return }
        userCategories.remove(at: categoryIndex)
        saveCategoriesToPersistentStore()
    }
    
    // MARK: - Persistence
    func saveBillsToPersistentStore() {
        guard let url = persistentBillsFileURL else { return }
        do{
            let data = try PropertyListEncoder().encode(self.userBills)
            try data.write(to: url)
            print("Bill Saved Succesfully")
        } catch {
            print("Error encoding bill data")
            print(error.localizedDescription)
        }
    }
    func loadBillData() {
        let fm = FileManager.default
        guard let url = persistentBillsFileURL, fm.fileExists(atPath: url.path) else { return }
        do{
            let data = try Data(contentsOf: url)
            self.userBills = try PropertyListDecoder().decode([Bill].self, from: data)
        } catch {
            print("Error loading bill data")
            print(error.localizedDescription)
        }
    }
    func saveCategoriesToPersistentStore() {
        guard let url = persistentCategoriesFileURL else { return }
        do {
            let data = try PropertyListEncoder().encode(self.userCategories)
            try data.write(to: url)
        } catch {
            print("Error saving Category data")
            print(error.localizedDescription)
        }
    }
    
    func loadCategoryData() {
        let fm = FileManager.default
        guard let url = persistentCategoriesFileURL, fm.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            self.userCategories = try PropertyListDecoder().decode([Category].self, from: data)
            print("Category Loaded")
        } catch {
            print("Error loading Category data")
            print(error.localizedDescription)
        }
    }
    
}
