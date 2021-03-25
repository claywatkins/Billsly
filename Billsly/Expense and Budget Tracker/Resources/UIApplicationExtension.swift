//
//  UIApplicationExtension.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/25/21.
//

import UIKit

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
