//
//  HomeWidgetSample.swift
//  HomeWidgetSample
//

import AppIntents
import SwiftUI
import WidgetKit

private func l10n(_ key: String) -> LocalizedStringResource {
    LocalizedStringResource(stringLiteral: key)
}

struct MapStatsEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let payload: MapStatsPayloadDTO?
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MapStatsEntry {
        MapStatsEntry(date: Date(), configuration: ConfigurationAppIntent(), payload: nil)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> MapStatsEntry {
        let payload = loadMapStatsPayload(mode: configuration.mapMode)
        return MapStatsEntry(date: Date(), configuration: configuration, payload: payload)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<MapStatsEntry> {
        let payload = loadMapStatsPayload(mode: configuration.mapMode)
        let entry = MapStatsEntry(date: Date(), configuration: configuration, payload: payload)
        let refresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        return Timeline(entries: [entry], policy: .after(refresh))
    }
}

struct HomeWidgetSampleEntryView: View {
    var entry: MapStatsEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallContent
            case .systemMedium:
                mediumContent
            default:
                Text(l10n("widget.unsupported"))
            }
        }
    }

    private var smallContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let p = entry.payload, let first = p.columns.first {
                HStack(spacing: 4) {
                    Text(first.emoji)
                    Text(modeTitle)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                Text(first.value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(red: 0.16, green: 0.45, blue: 0.92))
                Text(p.summary)
                    .font(.caption2)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
            } else {
                Text(l10n("widget.appName"))
                    .font(.headline)
                Text(l10n("widget.fallback.small"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(10)
    }

    private var mediumContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(modeTitle)
                    .font(.caption)
                    .fontWeight(.bold)
                Spacer()
            }
            if let p = entry.payload {
                HStack(alignment: .top, spacing: 8) {
                    ForEach(Array(p.columns.enumerated()), id: \.offset) { _, col in
                        VStack(spacing: 4) {
                            Text(col.emoji)
                                .font(.title3)
                            Text(col.value)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.7)
                            Text(col.label)
                                .font(.system(size: 9))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                Text(p.summary)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                if let e = p.encouragement {
                    Text(e)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                }
            } else {
                Text(l10n("widget.fallback.medium"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
    }

    private var modeTitle: String {
        switch entry.configuration.mapMode {
        case .detail:
            return String(localized: "widget.mode.record")
        case .japan:
            return String(localized: "widget.mode.japan")
        case .world:
            return String(localized: "widget.mode.world")
        }
    }
}

struct HomeWidgetSample: Widget {
    let kind: String = "HomeWidgetSample"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, provider: Provider()) { entry in
            HomeWidgetSampleEntryView(entry: entry)
                .containerBackground(Color.white, for: .widget)
        }
        .configurationDisplayName(l10n("widget.config.displayName"))
        .description(l10n("widget.config.description"))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    HomeWidgetSample()
} timeline: {
    MapStatsEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        payload: MapStatsPayloadDTO(
            viewType: "detail",
            columns: [
                MapStatsColumnDTO(emoji: "📍", value: "12", label: "Places"),
                MapStatsColumnDTO(emoji: "🍜", value: "5", label: "Posts"),
                MapStatsColumnDTO(emoji: "📅", value: "30日", label: "Active days"),
            ],
            summary: "Your meals are recorded for 30 days ✨",
            encouragement: "🔥 2-week streak｜2 more weeks to hit 4"
        )
    )
}
