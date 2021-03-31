//
//  CategoryPopoverViewController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/10/21.
//

import UIKit

protocol CategoryCellTapped {
    func categoryCellTapped(name: String)
}

class CategoryPopoverViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCategoryButton: UIButton!
    
    // MARK: - Properties
    var userController = UserController.shared
    var delegate: CategoryCellTapped?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsHelper.blackCoral
        tableView.backgroundColor = ColorsHelper.blackCoral
        tableView.layer.cornerRadius = 12
        categoriesLabel.textColor = ColorsHelper.cultured
        addCategoryButton.tintColor = ColorsHelper.cultured
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDefaultCategories()
        userController.loadCategoryData()
    }
    
    // MARK: - Methods
    private func loadDefaultCategories() {
        if userController.userCategories.isEmpty {
            let defaultCategories: [Category] = [
                Category(name: "Subscription"),
                Category(name: "Utility"),
                Category(name: "Rent"),
                Category(name: "Mortgage"),
                Category(name: "Loan"),
                Category(name: "Credit Card"),
                Category(name: "Insurance"),
                Category(name: "Car Loan")
            ]
            for i in defaultCategories {
                userController.userCategories.append(i)
            }
            userController.saveCategoriesToPersistentStore()
        }
    }
    
    // MARK: - IBActions
    @IBAction func addCategoryButtonTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Add a Category", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.placeholder = "Category Name"
        }
        ac.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
            let firstTextField = ac.textFields![0]
            guard let name = firstTextField.text else { return }
            self.userController.createCategory(name: name)
            self.tableView.reloadData()
        }))
        self.present(ac, animated: true)
    }
}

// MARK: - Extension
extension CategoryPopoverViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userController.alphabetizedCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryTableViewCell else { return UITableViewCell()}
        cell.category = userController.alphabetizedCategories[indexPath.row]
        cell.contentView.backgroundColor = ColorsHelper.slateGray
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = userController.alphabetizedCategories[indexPath.row].name
        delegate?.categoryCellTapped(name: name)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = userController.alphabetizedCategories[indexPath.row]
            userController.deleteCategoryData(category: category)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}


