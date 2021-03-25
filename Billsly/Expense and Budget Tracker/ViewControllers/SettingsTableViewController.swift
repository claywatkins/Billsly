//
//  SettingsTableViewController.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/25/21.
//

import UIKit
import MessageUI
import StoreKit

protocol reloadHomeView {
    func usernameChanged()
}

class SettingsTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var addNameTextField: UITextField!
    @IBOutlet weak var saveNameButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    
    // MARK: - Properties
    let userController = UserController.shared
    let appURLForRating = ""
    let appURLForSharing = ""
    let supportEmail = "watkinsclayton921@gmail.com"
    var delegate: reloadHomeView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        getAppVersion()
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Methods
    private func configureViews() {
        view.backgroundColor = ColorsHelper.blackCoral
        navigationController?.navigationBar.barTintColor = ColorsHelper.blackCoral
        addNameTextField.textColor = ColorsHelper.cultured
        addNameTextField.backgroundColor = ColorsHelper.slateGray
        addNameTextField.layer.borderWidth = 1
        addNameTextField.layer.borderColor = ColorsHelper.apricot.cgColor
        addNameTextField.layer.cornerRadius = 8
        addNameTextField.attributedPlaceholder = NSAttributedString(string: "Add your name",
                                                                    attributes: [NSAttributedString.Key.foregroundColor : ColorsHelper.cultured])
    }
    
    private func getAppVersion(){
        if let appVersion = UIApplication.appVersion {
            versionLabel.text = "Billsly App version \(appVersion)"
        }
    }
    
    private func promptRating() {
        if let url = URL(string: appURLForRating) {
            UIApplication.shared.open(url)
        } else {
            print("error with app store URL")
        }
    }
    
    private func shareApp() {
        if let appURL = NSURL(string: appURLForSharing) {
            
            let objectsToShare: [Any] = [appURL]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
            activityVC.popoverPresentationController?.sourceView = tableView
            
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    private func sendTip() {
        
    }
    
    // MARK: - IBActions
    @IBAction func homeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveNameButtonTapped(_ sender: Any) {
        guard let name = addNameTextField.text, !name.isEmpty else {
            let ac = UIAlertController(title: "Name missing", message: "Please add a name before saving", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            return present(ac, animated: true)
        }
        UserDefaults.standard.setValue(name, forKey: "username")
        let ac = UIAlertController(title: "Name updated", message: "Name changed successfully", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(ac, animated: true)
    }
    
    @IBAction func twitterHandleTapped(_ sender: Any) {
        let twitterHandle = "CaptainnClayton"
        let appURL = URL(string: "twitter://user?screen_name=\(twitterHandle)")!
        let webURL = URL(string: "https://twitter.com/\(twitterHandle)")!
        
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL as URL) {
            application.open(appURL)
        } else {
            application.open(webURL)
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return 4
        case 3: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 35
        case 1: return 35
        case 2: return 35
        case 3: return 6
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath {
        case [2, 0]: promptRating()
            tableView.deselectRow(at: indexPath, animated: true)
        case [2, 1]: shareApp()
            tableView.deselectRow(at: indexPath, animated: true)
        case [2, 2]: composeShareEmail()
            tableView.deselectRow(at: indexPath, animated: true)
        case [2, 2]: sendTip()
            tableView.deselectRow(at: indexPath, animated: true)
        default: print("no class function triggered for index path: \(indexPath)")
        }
    }
    
    
}

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    
    func composeShareEmail() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let messageBody: String
        let deviceModelName = UIDevice.modelName
        let iOSVersion = UIDevice.current.systemVersion
        let topDivider = "------- Developer Info -------"
        let divider = "------------------------------"
        
        if let appVersion = UIApplication.appVersion {
            
            messageBody =  "\n\n\n\n\(topDivider)\nApp version: \(appVersion)\nDevice model: \(deviceModelName)\niOS version: \(iOSVersion)\n\(divider)"
        } else {
            messageBody = "\n\n\n\n\(topDivider)\nDevice model: \(deviceModelName)\niOS version: \(iOSVersion)\n\(divider)"
        }
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([supportEmail])
        mailComposerVC.setSubject("Your App Feedback")
        mailComposerVC.setMessageBody(messageBody, isHTML: false)
        return mailComposerVC
    }
    
    /// This alert gets shown if the device is a simulator, doesn't have Apple mail set up, or if mail in not available due to connectivity issues.
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send email. Please check email configuration and internet connection and try again.", preferredStyle: .alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
