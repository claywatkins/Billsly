//
//  ColorsHelper.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 3/20/21.
//

import UIKit

class ColorsHelper {
    static let independence = UIColor(red: 85, green: 91, blue: 110)
    static let morningBlue = UIColor(red: 137, green: 176, blue: 174)
    static let powderBlue = UIColor(red: 190, green: 227, blue: 219)
    static let cultured = UIColor(red: 250, green: 249, blue: 249)
    static let apricot = UIColor(red: 255, green: 214, blue: 186)
    static let celadonGreen = UIColor(red: 54, green: 130, blue: 127)
    static let raisinBlack = UIColor(red: 37, green: 35, blue: 35)
    static let slateGray = UIColor(red: 112, green: 121, blue: 140)
    static let bone = UIColor(red: 218, green: 210, blue: 188)
    static let grullo = UIColor(red: 169, green: 153, blue: 133)
    static let blackCoral = UIColor(red: 73, green: 88, blue: 103)
    static let orangeRedCrayola = UIColor(red: 254, green: 95, blue: 85)
    static let laurelGreen = UIColor(red: 176, green: 197, blue: 146)
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
