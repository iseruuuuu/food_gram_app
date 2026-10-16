//
//  RecentPostPayload.swift
//  HomeWidgetSample
//

import Foundation
import UIKit

struct RecentPostPayloadDTO: Codable {
    let postId: Int
    let restaurant: String
    let foodName: String
    let foodTag: String
    let star: Double
    let createdAtDisplay: String
    let imageFileName: String?
    let imageUrl: String?
}

func loadRecentPostPayload() -> RecentPostPayloadDTO? {
    let suite = UserDefaults(suiteName: MapStatsAppGroup.id)
    guard let json = suite?.string(forKey: "recent_post_payload"),
          let data = json.data(using: .utf8) else {
        return nil
    }
    return try? JSONDecoder().decode(RecentPostPayloadDTO.self, from: data)
}

func loadRecentPostThumbnailImage() -> UIImage? {
    let suite = UserDefaults(suiteName: MapStatsAppGroup.id)
    guard let base64 = suite?.string(forKey: "recent_post_image_base64"),
          !base64.isEmpty,
          let data = Data(base64Encoded: base64) else {
        return nil
    }
    return UIImage(data: data)
}
