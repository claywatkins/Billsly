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
    @Environment(\.widgetFamily) var family
    var body: some View {
        if family == .systemSmall {
            SmallWidget(entry: entry)
        } else {
            MediumWidget(entry: entry)
        }
    }
    
}

struct SmallWidget: View {
    var entry: Provider.Entry
    var body: some View {
        ZStack {
            Color.init(ColorsHelper.blackCoral)
            VStack(alignment: .center, spacing: 6) {
                Text("Your next bill is:")
                    .font(.headline)
                    .foregroundColor(Color.init(ColorsHelper.cultured))
                    .padding(.top)
                Text(entry.bill.name)
                    .foregroundColor(Color.init(ColorsHelper.cultured))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text("It's due on:")
                    .font(.headline)
                    .foregroundColor(Color.init(ColorsHelper.cultured))
                Text(entry.bill.dueByDate, style: .date)
                    .foregroundColor(Color.init(ColorsHelper.cultured))
                    .minimumScaleFactor(0.5)
                HStack {
                    Image("BillslyAppLogo")
                        .resizable()
                        .frame(width: 35, height: 35)
                }
            }.padding(3)
        }
    }
}

struct MediumWidget: View {
    var entry: Provider.Entry
    var body: some View {
        ZStack {
            Color.init(ColorsHelper.blackCoral)
            HStack {
                VStack(alignment: .center, spacing: 6) {
                    Text("Your next bill is:")
                        .font(.headline)
                        .foregroundColor(Color.init(ColorsHelper.cultured))
                        .padding(.top)
                    Text(entry.bill.name)
                        .foregroundColor(Color.init(ColorsHelper.cultured))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("It's due on:")
                        .font(.headline)
                        .foregroundColor(Color.init(ColorsHelper.cultured))
                    Text(entry.bill.dueByDate, style: .date)
                        .foregroundColor(Color.init(ColorsHelper.cultured))
                        .minimumScaleFactor(0.5)
                    HStack {

                        Image("BillslyAppLogo")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                }.padding(3)

                VStack(spacing: 30) {

                        Button {

                        } label: {
                            Text("I paid a bill")
                                .font(.headline)
                                .foregroundColor(Color.init(ColorsHelper.cultured))
                                .padding()
                                .overlay(RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.init(ColorsHelper.apricot)))
                        }
                    .shadow(color: Color.black, radius: 2, x: 0, y: 4)


                    Button {

                    } label: {
                        Text("Manage Bills")
                            .font(.headline)
                            .foregroundColor(Color.init(ColorsHelper.cultured))
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.init(ColorsHelper.apricot)))
                    }
                    .shadow(color: Color.black, radius: 2, x: 0, y: 4)
                } .padding(.leading)
            }
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
        .configurationDisplayName("Billsly")
        .description("Keep track of your bills even easier with a widget!")
        .supportedFamilies([.systemSmall])
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
        Group {
            BillslyWidgetsEntryView(entry: BillEntry(bill: bill))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            BillslyWidgetsEntryView(entry: BillEntry(bill: bill))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
