//
//  WidgetDataBills.swift
//  Expense and Budget Tracker
//
//  Created by Clayton Watkins on 10/5/21.
//

import Foundation
import SwiftUI
import WidgetKit

@available(iOS 14, *)
struct WidgetData {
    @AppStorage("billsData", store: UserDefaults(suiteName: "group.com.claytonwatkins.Billsly")) var widgetBillData: Data = Data()
    let billToWidget: Bill
    
    func storeBillsInUserDefaults() {
        guard let data = try? JSONEncoder().encode(billToWidget) else { print("could not encode"); return }
        widgetBillData = data
        WidgetCenter.shared.reloadAllTimelines()
        print(String(decoding: widgetBillData, as: UTF8.self))
    }
}
