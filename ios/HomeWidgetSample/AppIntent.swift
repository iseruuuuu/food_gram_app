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
        TypeDisplayRepresentation(name: "Statistics type")
    }

    static var caseDisplayRepresentations: [MapStatsViewMode: DisplayRepresentation] {
        [
            .detail: "Record",
            .japan: "Japan",
            .world: "World",
        ]
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Map statistics" }
    static var description: IntentDescription {
        "Choose record, Japan prefectures, or world countries."
    }

    @Parameter(title: "Type", default: .detail)
    var mapMode: MapStatsViewMode
}
