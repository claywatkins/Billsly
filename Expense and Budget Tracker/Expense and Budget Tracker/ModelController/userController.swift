//
//  ExpenseController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/3/21.
//

import Foundation

class UserController {
    
    // MARK: - Properties
    static let shared = UserController()
    var userExpenses: [Expense] = []
    var userBills: [Bill] = []
    var persistentFileURL: URL? {
        let fm = FileManager.default
        let documents = fm.urls(for: .documentDirectory, in: .userDomainMask).first
        return documents?.appendingPathExtension("userData.plist")
    }
    var paidBills: [Bill] {
        let bills = userBills
        let filteredPaidBills = bills.filter{ (bills) -> Bool in bills.hasBeenPaid == true }
        return filteredPaidBills
    }
    var unpaidBills: [Bill] {
        let bills = userBills
        let filteredUnpaidBills = bills.filter { (bills) -> Bool in bills.hasBeenPaid == false }
        return filteredUnpaidBills
    }
    
    // MARK: - CRUD
    func saveBillsToPersistentStore() {
        guard let url = persistentFileURL else { return }
        do{
            let data = try PropertyListEncoder().encode(self.userBills)
            try data.write(to: url)
        } catch {
            print("Error encoding bill data")
        }
    }
    
    func saveExpensesToPersistentStore() {
        guard let url = persistentFileURL else { return }
        do{
            let data = try PropertyListEncoder().encode(self.userExpenses)
            try data.write(to: url)
        } catch {
            print("Error encoding expense data")
        }
    }
    
    func loadBillData() {
        let fm = FileManager.default
        guard let url = persistentFileURL, fm.fileExists(atPath: url.path) else { return }
        do{
            let data = try Data(contentsOf: url)
            self.userBills = try PropertyListDecoder().decode([Bill].self, from: data)
        } catch {
            print("Error loading bill data")
        }
    }
    
    func loadExpenseData() {
        let fm = FileManager.default
        guard let url = persistentFileURL, fm.fileExists(atPath: url.path) else { return }
        do{
            let data = try Data(contentsOf: url)
            self.userExpenses = try PropertyListDecoder().decode([Expense].self, from: data)
        } catch {
            print("Error loading Expense data")
        }
    }
    
    func deleteBillData(bill: Bill){
        guard let billIndex = userBills.firstIndex(of: bill) else { return }
        userBills.remove(at: billIndex)
        saveBillsToPersistentStore()
    }
    
    func deleteExpenseData(expense: Expense){
        guard let expenseIndex = userExpenses.firstIndex(of: expense) else { return }
        userExpenses.remove(at: expenseIndex)
        saveExpensesToPersistentStore()
    }
    
    func updateBillHasBeenPaid(bill: Bill) {
        if let billIndex = userBills.firstIndex(of: bill) {
            userBills[billIndex].hasBeenPaid.toggle()
        }
        saveBillsToPersistentStore()
    }
}
