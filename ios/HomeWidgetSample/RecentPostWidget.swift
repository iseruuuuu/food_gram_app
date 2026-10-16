//
//  RecentPostWidget.swift
//  HomeWidgetSample
//

import SwiftUI
import UIKit
import WidgetKit

private func recentPostL10n(_ key: String) -> LocalizedStringResource {
    LocalizedStringResource(stringLiteral: key)
}

struct RecentPostEntry: TimelineEntry {
    let date: Date
    let payload: RecentPostPayloadDTO?
    let image: UIImage?
}

struct RecentPostTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> RecentPostEntry {
        RecentPostEntry(
            date: Date(),
            payload: RecentPostPayloadDTO(
                postId: 0,
                restaurant: "FoodGram",
                foodName: "",
                foodTag: "🍜",
                star: 4.5,
                createdAtDisplay: "2026/10/16",
                imageFileName: nil,
                imageUrl: nil
            ),
            image: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (RecentPostEntry) -> Void) {
        let payload = loadRecentPostPayload()
        let image = loadRecentPostThumbnailImage()
        completion(RecentPostEntry(date: Date(), payload: payload, image: image))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RecentPostEntry>) -> Void) {
        let payload = loadRecentPostPayload()
        let image = loadRecentPostThumbnailImage()
        let entry = RecentPostEntry(date: Date(), payload: payload, image: image)
        let refresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

private let brandOrange = Color(red: 0.91, green: 0.537, blue: 0.196) // #E88932

struct RecentPostWidgetEntryView: View {
    var entry: RecentPostEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallView
            case .systemMedium:
                mediumView
            default:
                smallView
            }
        }
    }

    // MARK: - Small Widget (全面写真 + 下部にシンプルに店名のみ)

    private var smallView: some View {
        ZStack(alignment: .bottomLeading) {
            if let payload = entry.payload {
                photoOrPlaceholderBackground

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.22),
                        Color.black.opacity(0.76),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Text(displayRestaurant(payload))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                emptyStateView(isSmall: true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Medium Widget (左に料理写真、右に店名・料理名・日付・評価)

    private var mediumView: some View {
        Group {
            if let payload = entry.payload {
                HStack(spacing: 12) {
                    ZStack(alignment: .topLeading) {
                        photoOrPlaceholderSquare
                            .frame(width: 128, height: 128)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                        if !firstEmoji(from: payload.foodTag).isEmpty {
                            Text(firstEmoji(from: payload.foodTag))
                                .font(.system(size: 15))
                                .padding(5)
                                .background(.ultraThinMaterial, in: Circle())
                                .padding(6)
                        }
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 4) {
                            Text(recentPostL10n("recentWidget.badge"))
                                .font(.system(size: 10.5, weight: .bold))
                                .foregroundStyle(brandOrange)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2.5)
                                .background(brandOrange.opacity(0.14), in: Capsule())
                            Spacer(minLength: 0)
                            if !payload.createdAtDisplay.isEmpty {
                                Text(payload.createdAtDisplay)
                                    .font(.system(size: 10.5, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }

                        Spacer(minLength: 0)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(brandOrange)
                            Text(displayRestaurant(payload))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                        }

                        if !payload.foodName.isEmpty {
                            Text(payload.foodName)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        if payload.star > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.yellow)
                                Text(String(format: "%.1f", payload.star))
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.primary)
                            }
                        }

                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
                .padding(11)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                emptyStateView(isSmall: false)
                    .padding(12)
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private var photoOrPlaceholderBackground: some View {
        if let uiImage = entry.image {
            GeometryReader { geo in
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
        } else {
            LinearGradient(
                colors: [brandOrange.opacity(0.85), Color(red: 0.72, green: 0.35, blue: 0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    @ViewBuilder
    private var photoOrPlaceholderSquare: some View {
        if let uiImage = entry.image {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            LinearGradient(
                colors: [brandOrange.opacity(0.85), Color(red: 0.72, green: 0.35, blue: 0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay {
                Image(systemName: "fork.knife")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
    }

    private func emptyStateView(isSmall: Bool) -> some View {
        VStack(alignment: .center, spacing: 6) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: isSmall ? 24 : 28))
                .foregroundStyle(brandOrange)
            Text(recentPostL10n("recentWidget.empty.title"))
                .font(.system(size: isSmall ? 13 : 14, weight: .bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
            Text(recentPostL10n("recentWidget.empty.subtitle"))
                .font(.system(size: isSmall ? 10.5 : 12))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(isSmall ? 10 : 0)
    }

    private func displayRestaurant(_ payload: RecentPostPayloadDTO) -> String {
        let rest = payload.restaurant.trimmingCharacters(in: .whitespacesAndNewlines)
        if !rest.isEmpty {
            return rest
        }
        let food = payload.foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !food.isEmpty {
            return food
        }
        return "FoodGram"
    }

    private func firstEmoji(from foodTag: String) -> String {
        let first = foodTag
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
        return first ?? ""
    }
}

struct RecentPostWidget: Widget {
    let kind: String = "RecentPostWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RecentPostTimelineProvider()) { entry in
            RecentPostWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(UIColor.systemBackground)
                }
        }
        .contentMarginsDisabled()
        .configurationDisplayName(String(localized: "recentWidget.config.displayName"))
        .description(String(localized: "recentWidget.config.description"))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
