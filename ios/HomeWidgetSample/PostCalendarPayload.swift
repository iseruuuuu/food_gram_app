//
//  PostCalendarPayload.swift
//  HomeWidgetSample
//

import Foundation
import UIKit

struct PostCalendarPayloadDTO: Codable {
    let postedDates: [String]
    let postedEmojis: [String: String]?
    let customTagIcons: [String: String]?
    let updatedAt: String?
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

/// 指定した日付（月）に含まれる投稿日とスタンプのマップ（Day 1...31 -> Stamp）を返す。
func postedDayStampsInMonth(for referenceDate: Date, payload: PostCalendarPayloadDTO?) -> [Int: PostCalendarDayStamp] {
    guard let payload else {
        return [:]
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

    var result: [Int: PostCalendarDayStamp] = [:]
    let emojiMap = payload.postedEmojis ?? [:]

    for dateStr in payload.postedDates where dateStr.hasPrefix(prefix) {
        let dayPart = dateStr.dropFirst(prefix.count).prefix(2)
        if let day = Int(dayPart), (1...31).contains(day) {
            let rawTag = emojiMap[dateStr] ?? ""
            result[day] = resolveDayStamp(rawTag: rawTag, customTagImages: customTagImages)
        }
    }

    for (dateStr, rawTag) in emojiMap where dateStr.hasPrefix(prefix) {
        let dayPart = dateStr.dropFirst(prefix.count).prefix(2)
        if let day = Int(dayPart), (1...31).contains(day) {
            result[day] = resolveDayStamp(rawTag: rawTag, customTagImages: customTagImages)
        }
    }

    return result
}
