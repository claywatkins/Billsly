//
//  BillslyWidgets.swift
//  BillslyWidgets
//
//  Created by Clayton Watkins on 10/4/21.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    @AppStorage("billData", store: UserDefaults(suiteName: "group.com.claytonwatkins.Billsly")) var widgetBillData: Data = Data()
    func placeholder(in context: Context) -> BillEntry {
        let bill = Bill(identifier: UUID().uuidString,
                        name: "Rent",
                        dollarAmount: 22.44,
                        dueByDate: Date(),
                        category: Category(name: "Rent"),
                        isOn30th: false,
                        hasImage: nil)
        return BillEntry(bill: bill)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (BillEntry) -> ()) {
        guard let bill = try? JSONDecoder().decode(Bill.self, from: widgetBillData) else { return }
        let entry = BillEntry(bill: bill)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let bill = try? JSONDecoder().decode(Bill.self, from: widgetBillData) else { return }
        let entry = BillEntry(bill: bill)
        let timeline = Timeline(entries: [entry],
                                policy: .never)
        completion(timeline)
    }
}

struct BillEntry: TimelineEntry {
    let date: Date = Date()
    let bill: Bill
}

struct BillslyWidgetsEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        
        ZStack {
            Color.init(ColorsHelper.blackCoral)
            VStack(alignment: .center, spacing: 6) {
                Text("Your next bill is:")
                    .font(.headline)
                    .foregroundColor(Color.init(ColorsHelper.cultured))
                    .minimumScaleFactor(0.5)
                    .padding(.top)
                Text(entry.bill.name)
                    .foregroundColor(Color.init(ColorsHelper.cultured))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text("It's due on:")
                    .font(.headline)
                    .foregroundColor(Color.init(ColorsHelper.cultured))
                    .minimumScaleFactor(0.5)
                Text(entry.bill.dueByDate, style: .date)
                    .foregroundColor(Color.init(ColorsHelper.cultured))
                    .minimumScaleFactor(0.5)
                HStack {
                    Spacer()
                    Image("BillslyAppLogo")
                        .resizable()
                        .frame(width: 35, height: 35)
                    
                }
            }.padding(3)
            
            
        }
    }
}

@main
struct BillslyWidgets: Widget {
    let kind: String = "BillslyWidgets"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BillslyWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct BillslyWidgets_Previews: PreviewProvider {
    static let bill = Bill(identifier: UUID().uuidString,
                           name: "Hyundai Car Payment",
                           dollarAmount: 22.44,
                           dueByDate: Date(),
                           category: Category(name: "Rent"),
                           isOn30th: false,
                           hasImage: nil)
    static var previews: some View {
        BillslyWidgetsEntryView(entry: BillEntry(bill: bill))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
