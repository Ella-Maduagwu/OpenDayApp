//
//  Room.swift
//  OpenDayApp
//
//  Created by Emmanuella Maduagwu on 21/11/2024.
//

import Foundation
typealias RoomData = [String: Any]
struct Room {
    var id: String
    var name: String
    var buildingID: String

    init?(data: RoomData, buildingID: String) {
        guard let name = data["name"] as? String else {
            return nil
        }
        self.id = UUID().uuidString
        self.name = name
        self.buildingID = buildingID
    }
}
