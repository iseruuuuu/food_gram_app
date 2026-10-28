//
//  OpenCalendarDayIntent.swift
//
//  ウィジェット拡張とアプリ本体の両方からコンパイルする。
//  どちらのプロセスで perform が走っても、App Group に日付が残る。
//

import AppIntents
import Foundation

/// アプリ本体の対応 OS は 15.5 なので、iOS 16 の App Intents はこの型だけに閉じる。
@available(iOS 16.0, *)
struct OpenCalendarDayIntent: AppIntent {
    static var title: LocalizedStringResource = "calendarWidget.day.intent"
    static var openAppWhenRun = true

    static let storageKey = "calendar_day_launch"
    static let appGroupId = "group.com.FoodGram.ios"

    @Parameter(title: "Date")
    var dateKey: String

    init() {
        dateKey = ""
    }

    init(dateKey: String) {
        self.dateKey = dateKey
    }

    func perform() async throws -> some IntentResult {
        let trimmed = dateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .result()
        }
        let defaults = UserDefaults(suiteName: Self.appGroupId)
        defaults?.set(trimmed, forKey: Self.storageKey)
        defaults?.synchronize()
        return .result()
    }
}
