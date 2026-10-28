//
//  PostCalendarPayload.swift
//  HomeWidgetSample
//

import Foundation
import UIKit

struct PostCalendarPayloadDTO: Codable {
    let postedDates: [String]
    let postedEmojis: [String: String]?
    let postedCounts: [String: Int]?
    let customTagIcons: [String: String]?
    let updatedAt: String?
}

struct PostCalendarMonthMarks {
    let stamps: [Int: PostCalendarDayStamp]
    let counts: [Int: Int]
}

enum PostCalendarDayStamp {
    case emoji(String)
    case customImage(UIImage)
}

private let customTagFallbackEmojiMap: [String: String] = [
    "tag:meibutsu": "🍱",
    "tag:souvenir": "🎁",
    "tag:udon": "🍜",
    "tag:soba": "🍜",
    "tag:yakisoba": "🍝",
    "tag:tonkatsu": "🍖",
    "tag:tantanmen": "🍜",
    "tag:takoyaki": "🐙",
    "tag:tsukune": "🍢",
    "tag:omurice": "🍳",
    "tag:tamagoyaki": "🥚",
    "tag:frenchtoast": "🍞",
    "tag:montblanc": "🧁",
    "tag:stew": "🍲",
    "tag:hamburg": "🥩",
    "tag:yakiniku": "🥩",
    "tag:tendon": "🍤",
    "tag:katsudon": "🍚",
    "tag:kaisendon": "🍣",
    "tag:mochi": "🍡",
    "tag:melonpan": "🥐",
    "tag:chahan": "🍚",
    "tag:okonomiyaki": "🥞",
    "tag:mapo": "🍲",
    "tag:gyutan": "🥩",
    "tag:xiaolongbao": "🥟",
    "tag:chikinnanban": "🍗",
    "tag:churro": "🥖",
    "tag:shu": "🧁",
]

func loadPostCalendarPayload() -> PostCalendarPayloadDTO? {
    let suite = UserDefaults(suiteName: MapStatsAppGroup.id)
    guard let json = suite?.string(forKey: "post_calendar_payload"),
          let data = json.data(using: .utf8) else {
        return nil
    }
    return try? JSONDecoder().decode(PostCalendarPayloadDTO.self, from: data)
}

/// タグ文字列（絵文字または `tag:xxx`）をカレンダー表示用のスタンプに変換する。
private func resolveDayStamp(
    rawTag: String,
    customTagImages: [String: UIImage]
) -> PostCalendarDayStamp {
    let trimmed = rawTag.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty {
        return .emoji("🍽️")
    }
    if trimmed.hasPrefix("tag:") {
        if let image = customTagImages[trimmed] {
            return .customImage(image)
        }
        let fallback = customTagFallbackEmojiMap[trimmed] ?? "🍽️"
        return .emoji(fallback)
    }
    return .emoji(trimmed)
}

/// 指定した月のスタンプと、その日の投稿件数を返す。
func postedMonthMarks(for referenceDate: Date, payload: PostCalendarPayloadDTO?) -> PostCalendarMonthMarks {
    guard let payload else {
        return PostCalendarMonthMarks(stamps: [:], counts: [:])
    }
    let calendar = Calendar.current
    let targetYear = calendar.component(.year, from: referenceDate)
    let targetMonth = calendar.component(.month, from: referenceDate)
    let prefix = String(format: "%04d-%02d-", targetYear, targetMonth)

    var customTagImages: [String: UIImage] = [:]
    if let rawIcons = payload.customTagIcons {
        for (tagId, base64) in rawIcons {
            if let data = Data(base64Encoded: base64),
               let img = UIImage(data: data) {
                customTagImages[tagId] = img
            }
        }
    }

    var stamps: [Int: PostCalendarDayStamp] = [:]
    var counts: [Int: Int] = [:]
    let emojiMap = payload.postedEmojis ?? [:]
    let countMap = payload.postedCounts ?? [:]

    func apply(dateStr: String, rawTag: String) {
        guard dateStr.hasPrefix(prefix) else { return }
        let dayPart = dateStr.dropFirst(prefix.count).prefix(2)
        guard let day = Int(dayPart), (1...31).contains(day) else { return }
        stamps[day] = resolveDayStamp(rawTag: rawTag, customTagImages: customTagImages)
        let count = countMap[dateStr] ?? 1
        counts[day] = max(count, 1)
    }

    for dateStr in payload.postedDates {
        apply(dateStr: dateStr, rawTag: emojiMap[dateStr] ?? "")
    }
    for (dateStr, rawTag) in emojiMap {
        apply(dateStr: dateStr, rawTag: rawTag)
    }

    return PostCalendarMonthMarks(stamps: stamps, counts: counts)
}
