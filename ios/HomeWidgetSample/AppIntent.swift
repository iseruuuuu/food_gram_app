//
//  AppIntent.swift
//  HomeWidgetSample
//

import AppIntents
import WidgetKit

enum MapStatsViewMode: String, AppEnum {
    case detail
    case japan
    case world

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: LocalizedStringResource("widget.intent.statisticsType"))
    }

    static var caseDisplayRepresentations: [MapStatsViewMode: DisplayRepresentation] {
        [
            .detail: DisplayRepresentation(title: LocalizedStringResource("widget.mode.record")),
            .japan: DisplayRepresentation(title: LocalizedStringResource("widget.mode.japan")),
            .world: DisplayRepresentation(title: LocalizedStringResource("widget.mode.world")),
        ]
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "widget.intent.title" }
    static var description: IntentDescription {
        IntentDescription("widget.intent.description")
    }

    @Parameter(title: "widget.intent.type", default: .detail)
    var mapMode: MapStatsViewMode
}
