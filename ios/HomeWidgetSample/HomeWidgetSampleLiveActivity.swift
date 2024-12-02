//
//  HomeWidgetSampleLiveActivity.swift
//  HomeWidgetSample
//

import ActivityKit
import WidgetKit
import SwiftUI

/// ライブアクティビティは、ロック画面やDynamic Islandに表示される動的なコンテンツを提供します。
struct HomeWidgetSampleAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct HomeWidgetSampleLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HomeWidgetSampleAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension HomeWidgetSampleAttributes {
    fileprivate static var preview: HomeWidgetSampleAttributes {
        HomeWidgetSampleAttributes(name: "World")
    }
}

extension HomeWidgetSampleAttributes.ContentState {
    fileprivate static var smiley: HomeWidgetSampleAttributes.ContentState {
        HomeWidgetSampleAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: HomeWidgetSampleAttributes.ContentState {
         HomeWidgetSampleAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: HomeWidgetSampleAttributes.preview) {
   HomeWidgetSampleLiveActivity()
} contentStates: {
    HomeWidgetSampleAttributes.ContentState.smiley
    HomeWidgetSampleAttributes.ContentState.starEyes
}
