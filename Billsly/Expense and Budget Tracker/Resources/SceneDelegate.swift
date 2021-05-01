//
//  SceneDelegate.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 2/15/21.
//

import UIKit
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        let userController = UserController.shared
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        for bill in userController.unpaidBills {
            let content = UNMutableNotificationContent()
            content.title = "Upcoming bill due tomorrow"
            content.body = "\(bill.name) is due tomorrow. Make sure to mark it as paid, after it's paid."
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
    
    
}

