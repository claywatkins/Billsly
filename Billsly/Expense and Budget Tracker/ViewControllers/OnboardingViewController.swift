//
//  OnboardingViewController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/20/21.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    let userController = UserController.shared
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        segueIfUsernameExists()
    }
   
    
    @IBAction func allowNotificationsTapped(_ sender: Any) {
        
    }
    @IBAction func takeMeInButtonTapped(_ sender: Any) {
        guard let username = nameTextField.text else { return }
        UserDefaults.standard.setValue(nil, forKey: "currentMonth")
        UserDefaults.standard.setValue(userController.isLoggedIn, forKey: "loggedIn")
        UserDefaults.standard.setValue(username, forKey: "username")
        segueIfUsernameExists()
    }
    
    
    private func segueIfUsernameExists() {
        if UserDefaults.standard.string(forKey: "username") != nil {
            performSegue(withIdentifier: "test", sender: self)
            self.view.backgroundColor = .clear
        }
    }
}
