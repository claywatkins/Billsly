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
    var persistentBillsFileURL: URL? {
        let fm = FileManager.default
        let documents = fm.urls(for: .documentDirectory, in: .userDomainMask).first
        return documents?.appendingPathExtension("userBills.plist")
    }
    var persistentExpensesFileURL: URL? {
        let fm = FileManager.default
        let documents = fm.urls(for: .documentDirectory, in: .userDomainMask).first
        return documents?.appendingPathExtension("userExpenses.plist")
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
    func createBill(name: String, dollarAmount: Double) {
        let newBill = Bill(name: name, dollarAmount: dollarAmount)
        userBills.append(newBill)
        print("Bill Added Successfully")
        saveBillsToPersistentStore()
        
    }
    
    func createExpense(name:String, dollarAmount: Double) {
        let newExpense = Expense(name: name, dollarAmount: dollarAmount)
        userExpenses.append(newExpense)
        print("Expense added Successfully")
        saveExpensesToPersistentStore()
    }
    
    func updateBillHasBeenPaid(bill: Bill) {
        if let billIndex = userBills.firstIndex(of: bill) {
            userBills[billIndex].hasBeenPaid.toggle()
        }
        saveBillsToPersistentStore()
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
    
    // MARK: - Persistence
    func saveBillsToPersistentStore() {
        guard let url = persistentBillsFileURL else { return }
        do{
            let data = try PropertyListEncoder().encode(self.userBills)
            try data.write(to: url)
            print("Bill Saved Succesfully")
        } catch {
            print("Error encoding bill data")
        }
    }
    
    func saveExpensesToPersistentStore() {
        guard let url = persistentExpensesFileURL else { return }
        do{
            let data = try PropertyListEncoder().encode(self.userExpenses)
            try data.write(to: url)
            print("Expense Saved Successfully")
        } catch {
            print("Error encoding expense data")
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
        }
    }
    
    func loadExpenseData() {
        let fm = FileManager.default
        guard let url = persistentExpensesFileURL, fm.fileExists(atPath: url.path) else { return }
        do{
            let data = try Data(contentsOf: url)
            self.userExpenses = try PropertyListDecoder().decode([Expense].self, from: data)
        } catch {
            print("Error loading Expense data")
        }
    }
    

    
}
