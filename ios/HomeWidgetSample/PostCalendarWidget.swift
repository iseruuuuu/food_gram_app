//
//  PostCalendarWidget.swift
//  HomeWidgetSample
//

import SwiftUI
import UIKit
import WidgetKit

struct PostCalendarEntry: TimelineEntry {
    let date: Date
    let postedDayStamps: [Int: PostCalendarDayStamp]
}

private let samplePreviewStamps: [Int: PostCalendarDayStamp] = [
    2: .emoji("🍜"),
    6: .emoji("🍛"),
    9: .emoji("🍣"),
    12: .emoji("🍔"),
    14: .emoji("🍰"),
    15: .emoji("🍕"),
    16: .emoji("🥗"),
    20: .emoji("🥩"),
    21: .emoji("☕️"),
    25: .emoji("🍝"),
    29: .emoji("🍱"),
]

struct PostCalendarTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> PostCalendarEntry {
        PostCalendarEntry(
            date: Date(),
            postedDayStamps: samplePreviewStamps
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PostCalendarEntry) -> Void) {
        let now = Date()
        let payload = loadPostCalendarPayload()
        let dayStamps = postedDayStampsInMonth(for: now, payload: payload)
        let effectiveStamps = (context.isPreview && dayStamps.isEmpty)
            ? samplePreviewStamps
            : dayStamps
        completion(PostCalendarEntry(date: now, postedDayStamps: effectiveStamps))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PostCalendarEntry>) -> Void) {
        let now = Date()
        let payload = loadPostCalendarPayload()
        let dayStamps = postedDayStampsInMonth(for: now, payload: payload)
        let entry = PostCalendarEntry(date: now, postedDayStamps: dayStamps)

        // 次の日付変更タイミング、または1時間後の早い方で更新
        let calendar = Calendar.current
        let nextMidnight = calendar.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 5),
            matchingPolicy: .nextTime
        )
        let oneHourLater = calendar.date(byAdding: .hour, value: 1, to: now)
        let refreshDate = [nextMidnight, oneHourLater].compactMap { $0 }.min() ?? now.addingTimeInterval(3600)

        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }
}

/// アプリのブランドオレンジ `AppTheme.primaryOrange` (#E88932)
private let brandOrange = Color(red: 0xE8 / 255.0, green: 0x89 / 255.0, blue: 0x32 / 255.0)
/// アプリ内のオレンジ背景色（ライト: `AppTheme.orangeLight` #FFF0DE / ダーク: `AppTheme.darkOrangeBackground` #4A321F）
private let appOrangeBackground = Color(
    UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0x4A / 255.0, green: 0x32 / 255.0, blue: 0x1F / 255.0, alpha: 1.0)
            : UIColor(red: 0xFF / 255.0, green: 0xF0 / 255.0, blue: 0xDE / 255.0, alpha: 1.0)
    }
)
/// 自分の投稿ピンのグラデーション（`#FFB067` -> `#E88932`）
private let ownPinOrangeGradient = LinearGradient(
    colors: [
        Color(red: 0xFF / 255.0, green: 0xB0 / 255.0, blue: 0x67 / 255.0),
        brandOrange,
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
private let weekdaySymbolsShort = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
private let weekdaySymbolsSingle = ["S", "M", "T", "W", "T", "F", "S"]

struct PostCalendarWidgetEntryView: View {
    var entry: PostCalendarEntry
    @Environment(\.widgetFamily) var family

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1 // Sunday
        return cal
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: entry.date)
    }

    private var todayDayNumber: Int {
        calendar.component(.day, from: entry.date)
    }

    /// 当月の各週（日曜始まり・7列）の日付配列（空白セルは nil）
    private var monthWeeks: [[Int?]] {
        let comps = calendar.dateComponents([.year, .month], from: entry.date)
        guard let firstOfMonth = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else {
            return []
        }
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) // 1 = Sun ... 7 = Sat
        let leadingEmptyCount = firstWeekday - 1

        var cells: [Int?] = Array(repeating: nil, count: leadingEmptyCount)
        for day in range {
            cells.append(day)
        }
        while cells.count % 7 != 0 {
            cells.append(nil)
        }

        var weeks: [[Int?]] = []
        for idx in stride(from: 0, to: cells.count, by: 7) {
            weeks.append(Array(cells[idx..<(idx + 7)]))
        }
        return weeks
    }

    var body: some View {
        switch family {
        case .systemSmall:
            calendarLayout(
                weekdaySymbols: weekdaySymbolsSingle,
                headerFontSize: 13.5,
                headerIconSize: 11,
                weekdayFontSize: 8.5,
                dayFontSize: 10.5,
                emojiFontSize: 12.5,
                circleSize: 20,
                horizontalPadding: 11,
                verticalPadding: 10,
                headerBottomSpacing: 5,
                weekdayBottomSpacing: 3
            )
        case .systemMedium:
            calendarLayout(
                weekdaySymbols: weekdaySymbolsShort,
                headerFontSize: 15,
                headerIconSize: 12,
                weekdayFontSize: 8.5,
                dayFontSize: 11,
                emojiFontSize: 13.5,
                circleSize: 21,
                horizontalPadding: 18,
                verticalPadding: 11,
                headerBottomSpacing: 5,
                weekdayBottomSpacing: 3
            )
        case .systemLarge:
            calendarLayout(
                weekdaySymbols: weekdaySymbolsShort,
                headerFontSize: 20,
                headerIconSize: 15,
                weekdayFontSize: 10.5,
                dayFontSize: 14,
                emojiFontSize: 18,
                circleSize: 33,
                horizontalPadding: 24,
                verticalPadding: 22,
                headerBottomSpacing: 14,
                weekdayBottomSpacing: 10
            )
        default:
            calendarLayout(
                weekdaySymbols: weekdaySymbolsShort,
                headerFontSize: 15,
                headerIconSize: 12,
                weekdayFontSize: 8.5,
                dayFontSize: 11,
                emojiFontSize: 13.5,
                circleSize: 21,
                horizontalPadding: 16,
                verticalPadding: 12,
                headerBottomSpacing: 6,
                weekdayBottomSpacing: 4
            )
        }
    }

    @ViewBuilder
    private func calendarLayout(
        weekdaySymbols: [String],
        headerFontSize: CGFloat,
        headerIconSize: CGFloat,
        weekdayFontSize: CGFloat,
        dayFontSize: CGFloat,
        emojiFontSize: CGFloat,
        circleSize: CGFloat,
        horizontalPadding: CGFloat,
        verticalPadding: CGFloat,
        headerBottomSpacing: CGFloat,
        weekdayBottomSpacing: CGFloat
    ) -> some View {
        let weeks = monthWeeks

        VStack(alignment: .leading, spacing: 0) {
            // Header: FoodGram フォーク＆ナイフアイコン + 月名 + 投稿日数ピルバッジ
            HStack(alignment: .center, spacing: 6) {
                Image(systemName: "fork.knife")
                    .font(.system(size: headerIconSize, weight: .bold))
                    .foregroundStyle(brandOrange)

                Text(monthTitle)
                    .font(.system(size: headerFontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Spacer(minLength: 0)

                if !entry.postedDayStamps.isEmpty {
                    HStack(spacing: 3) {
                        Text("🍽️")
                            .font(.system(size: max(weekdayFontSize, 8.5)))
                        Text("\(entry.postedDayStamps.count)")
                            .font(.system(size: max(weekdayFontSize + 1, 9.5), weight: .bold, design: .rounded))
                            .foregroundStyle(brandOrange)
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2.5)
                    .background(appOrangeBackground, in: Capsule())
                }
            }
            .padding(.bottom, headerBottomSpacing)

            // Weekday Header Row
            HStack(spacing: 0) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.system(size: weekdayFontSize, weight: .semibold, design: .rounded))
                        .tracking(0.3)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, weekdayBottomSpacing)

            // Calendar Grid
            VStack(spacing: 0) {
                ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { colIndex in
                            let day = week[colIndex]
                            dayCell(
                                day: day,
                                dayFontSize: dayFontSize,
                                emojiFontSize: emojiFontSize,
                                circleSize: circleSize
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func dayCell(
        day: Int?,
        dayFontSize: CGFloat,
        emojiFontSize: CGFloat,
        circleSize: CGFloat
    ) -> some View {
        if let day {
            let postedStamp = entry.postedDayStamps[day]
            let isToday = (day == todayDayNumber)

            ZStack {
                if let postedStamp {
                    // 投稿した日: アプリ内のオレンジ背景色（またはピンと同じブランドオレンジ）の上に料理絵文字・カスタムタグ画像を表示
                    Circle()
                        .fill(ownPinOrangeGradient)
                        .frame(width: circleSize, height: circleSize)

                    if isToday {
                        Circle()
                            .strokeBorder(Color.primary.opacity(0.65), lineWidth: 1.5)
                            .frame(width: circleSize + 3, height: circleSize + 3)
                    }

                    switch postedStamp {
                    case .emoji(let emoji):
                        Text(emoji)
                            .font(.system(size: emojiFontSize))
                            .lineLimit(1)
                    case .customImage(let uiImage):
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: circleSize * 0.72, height: circleSize * 0.72)
                    }
                } else if isToday {
                    // 今日（未投稿）: アプリ内の薄いオレンジ背景（orangeLight）＋ブランドオレンジ枠
                    Circle()
                        .fill(appOrangeBackground)
                        .frame(width: circleSize, height: circleSize)
                    Circle()
                        .strokeBorder(brandOrange, lineWidth: 1.3)
                        .frame(width: circleSize, height: circleSize)

                    Text("\(day)")
                        .font(.system(size: dayFontSize, weight: .bold, design: .rounded))
                        .foregroundStyle(brandOrange)
                } else {
                    // 通常の日（未投稿）
                    Text("\(day)")
                        .font(.system(size: dayFontSize, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.primary.opacity(0.72))
                }
            }
        } else {
            Color.clear
        }
    }
}

struct PostCalendarWidget: Widget {
    let kind: String = "PostCalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PostCalendarTimelineProvider()) { entry in
            PostCalendarWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(UIColor.systemBackground)
                }
        }
        .contentMarginsDisabled()
        .configurationDisplayName(String(localized: "calendarWidget.config.displayName"))
        .description(String(localized: "calendarWidget.config.description"))
        .supportedFamilies([.systemLarge])
    }
}
