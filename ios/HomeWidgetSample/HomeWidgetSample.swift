//
//  HomeWidgetSample.swift
//  HomeWidgetSample
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct HomeWidgetSampleEntryView: View {
    var entry: SimpleEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            switch family {
            case .systemSmall:
                smallWidgetUI
            case .systemMedium:
                mediumWidgetUI
            default:
                Text("Unsupported Size")
            }
        }
    }

    private var smallWidgetUI: some View {
        VStack {
            Image(systemName: "text.magnifyingglass")
                .resizable()
                .frame(width: 50, height: 50)
                .padding(EdgeInsets.init(top: 0, leading: 0, bottom: 5, trailing: 0))
            Text("Search Food")
                .font(.body)
                .fontWeight(Font.Weight.bold)
        }
       
    }

    private var mediumWidgetUI: some View {
        HStack(spacing: 12) {
            VStack {
                Image(systemName: "birthday.cake")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(EdgeInsets.init(top: 0, leading: 0, bottom: 5, trailing: 0))
                Text("Post Food")
                    .font(.footnote)
                    .fontWeight(Font.Weight.bold)
            }

            VStack {
                Image(systemName: "text.magnifyingglass")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(EdgeInsets.init(top: 0, leading: 0, bottom: 5, trailing: 0))
                Text("Seach Food")
                    .font(.footnote)
                    .fontWeight(Font.Weight.bold)
            }.padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))

            VStack {
                Image(systemName: "paperplane")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(EdgeInsets.init(top: 0, leading: 0, bottom: 5, trailing: 0))
                Text("Share Food")
                    .font(.footnote)
                    .fontWeight(Font.Weight.bold)
            }

        }
        
    }

}

struct HomeWidgetSample: Widget {
    let kind: String = "HomeWidgetSample"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, provider: Provider()) { entry in
            HomeWidgetSampleEntryView(entry: entry).containerBackground(Color(red: 1.0, green: 0.992, blue: 0.816), for: .widget)
        }
        .configurationDisplayName("Sample Widget")
        .description("This is an example widget.")
        // サポートするサイズを小（systemSmall）と中（systemMedium）のみに限定
        .supportedFamilies([.systemSmall, .systemMedium])
          
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = ""
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = ""
        return intent
    }
}

#Preview(as: .systemSmall) {
    HomeWidgetSample()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}
