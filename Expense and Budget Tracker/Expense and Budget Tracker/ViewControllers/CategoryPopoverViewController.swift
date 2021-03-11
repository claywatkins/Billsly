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
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    let userController = UserController.shared
    var delegate: CategoryCellTapped?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userController.loadCategoryData()
        print(userController.userCategories.count)
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
        return userController.userCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryTableViewCell else { return UITableViewCell()}
        cell.category = userController.userCategories[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = userController.userCategories[indexPath.row].name
        delegate?.categoryCellTapped(name: name)
        self.dismiss(animated: true, completion: nil)
    }
}


