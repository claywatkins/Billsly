//
//  BillslyWidgets.swift
//  BillslyWidgets
//
//  Created by Clayton Watkins on 10/4/21.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    let defaults = UserDefaults(suiteName: "group.com.claytonwatkins.Billsly")
    func placeholder(in context: Context) -> BillEntry {
        let bill = Bill(identifier: UUID().uuidString,
                        name: "Test Bill",
                        dollarAmount: 22.44,
                        dueByDate: Date(),
                        category: Category(name: "Rent"),
                        isOn30th: false,
                        hasImage: nil)
        return BillEntry(bill: bill)
    }

    func getSnapshot(in context: Context, completion: @escaping (BillEntry) -> ()) {
        let bills = defaults?.value(forKey: "nextThreeBills") as? [Bill] ?? nil
        let entry = BillEntry(name: "Test",
                              dueByDate: "Test")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [BillEntry] = []
        
        let defaults = UserDefaults(suiteName: "group.com.claytonwatkins.Billsly")
        let firstThreeBills = defaults?.value(forKey: "firstThreeBills") as? [Bill] ?? []


        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = BillEntry(date: entryDate,
                                  name: name,
                                  dueByDate: dueByDate,
                                  description: nil)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries,
                                policy: .atEnd)
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
        Text(entry.date, style: .time)
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
    static var previews: some View {
        BillslyWidgetsEntryView(entry: BillEntry(date: Date(), name: "Test Bill", dueByDate: "5-33-20", description: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
