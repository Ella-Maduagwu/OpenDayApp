//
//  BuildingStruct.swift
//  OpenDayApp
//
//  Created by Emmanuella Maduagwu on 21/11/2024.
//
import Foundation

struct BuildingStruct {
    var id: String
    var name: String
    var address: String
    var latitude: Double?
    var longitude: Double?

    init?(id: String, data: [String: Any]) {
        guard let name = data["name"] as? String,
              let address = data["address"] as? String else {
            return nil
        }
        self.id = id
        self.name = name
        self.address = address
        self.latitude = data["latitude"] as? Double
        self.longitude = data["longitude"] as? Double
    }
}
