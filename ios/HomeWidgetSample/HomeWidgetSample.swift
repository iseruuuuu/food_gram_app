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

private let smallStatValueBlue = Color(red: 0.16, green: 0.45, blue: 0.92)

/// 横長ウィジェット3列の数値色（左→右 緑・赤・青＝右から青・赤・緑）。
private let mediumColumnValueColors: [Color] = [
    Color(red: 0.204, green: 0.659, blue: 0.325), // #34A853 緑（左端）
    Color(red: 0.918, green: 0.263, blue: 0.208), // #EA4335 赤（中央）
    Color(red: 0.16, green: 0.45, blue: 0.92), // 青（右端）
]

private func splitSummaryIntoTwoLines(_ summary: String) -> (String, String)? {
    let separators: [Character] = ["、", "，"]
    for sep in separators {
        let parts = summary.split(separator: sep, maxSplits: 1, omittingEmptySubsequences: false)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if parts.count == 2 {
            return (parts[0], parts[1])
        }
    }
    return nil
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

    private var smallSummaryFont: Font { .system(size: 12) }

    private var smallContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let p = entry.payload, let first = p.columns.first {
                HStack(spacing: 5) {
                    Text(first.emoji)
                        .font(.system(size: 20))
                    Text(modeTitle)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(first.value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(smallStatValueBlue)
                    .minimumScaleFactor(0.75)
                    .lineLimit(1)
                Spacer(minLength: 0)
                if let pair = splitSummaryIntoTwoLines(p.summary) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pair.0)
                            .font(smallSummaryFont)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                            .lineLimit(3)
                            .minimumScaleFactor(0.58)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(pair.1)
                            .font(smallSummaryFont)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                            .lineLimit(3)
                            .minimumScaleFactor(0.58)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(p.summary)
                        .font(smallSummaryFont)
                        .fontWeight(.medium)
                        .lineLimit(5)
                        .minimumScaleFactor(0.58)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                Text(l10n("widget.appName"))
                    .font(.headline)
                Text(l10n("widget.fallback.small"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 9)
    }

    /// 横長ウィジェット：アイコン行・数値＋ラベル行・メッセージの縦の区切り
    private let mediumVerticalSectionSpacing: CGFloat = 6

    private var mediumContent: some View {
        VStack(alignment: .center, spacing: 0) {
            if let p = entry.payload {
                VStack(alignment: .center, spacing: mediumVerticalSectionSpacing) {
                    HStack(alignment: .center, spacing: 6) {
                        ForEach(Array(p.columns.enumerated()), id: \.offset) { _, col in
                            Text(col.emoji)
                                .font(.system(size: 24))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    HStack(alignment: .center, spacing: 6) {
                        ForEach(Array(p.columns.enumerated()), id: \.offset) { i, col in
                            VStack(spacing: 2) {
                                Text(col.value)
                                    .font(.system(size: 25, weight: .bold))
                                    .foregroundStyle(mediumColumnValueColors[min(i, 2)])
                                    .multilineTextAlignment(.center)
                                    .minimumScaleFactor(0.45)
                                    .lineLimit(2)
                                Text(col.label)
                                    .font(.system(size: 13.5, weight: .medium))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.65)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Text(p.summary)
                        .font(.system(size: 15, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.78)
                        .frame(maxWidth: .infinity)
                }
            } else {
                Text(l10n("widget.fallback.medium"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
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
        .configurationDisplayName(String(localized: "widget.config.displayName"))
        .description(String(localized: "widget.config.description"))
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
