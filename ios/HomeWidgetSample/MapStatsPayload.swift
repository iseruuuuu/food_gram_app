//
//  MapStatsPayload.swift
//  HomeWidgetSample
//

import Foundation

enum MapStatsAppGroup {
    static let id = "group.com.FoodGram.ios"
}

struct MapStatsColumnDTO: Codable {
    let emoji: String
    let value: String
    let label: String
}

struct MapStatsPayloadDTO: Codable {
    let viewType: String
    let columns: [MapStatsColumnDTO]
    let summary: String
    let encouragement: String?
}

func loadMapStatsPayload(mode: MapStatsViewMode) -> MapStatsPayloadDTO? {
    let suite = UserDefaults(suiteName: MapStatsAppGroup.id)
    let key = "map_stats_\(mode.rawValue)"
    guard let json = suite?.string(forKey: key),
          let data = json.data(using: .utf8) else {
        return nil
    }
    return try? JSONDecoder().decode(MapStatsPayloadDTO.self, from: data)
}
