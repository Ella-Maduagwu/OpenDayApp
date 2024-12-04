//
//  Room.swift
//  OpenDayApp
//
//  Created by Emmanuella Maduagwu on 21/11/2024.
//

import Foundation
import CoreLocation
typealias RoomData = [String: Any]
struct Room {
    var name: String
    var buildingID: String
    let minor : CLBeaconMinorValue
    let major : CLBeaconMajorValue
    
    init?(data: RoomData, buildingID: String) {
        guard let name = data["name"] as? String,
        let minorValue = data["minor"] as? Int,
        let majorValue = data["major"] as? Int else {
            return nil
        }
        self.name = name
        self.buildingID = buildingID
        self.minor = CLBeaconMinorValue(minorValue)
        self.major = CLBeaconMajorValue(majorValue)
    }
}

