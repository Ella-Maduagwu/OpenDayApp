//
//  Date+Extensions.swift
//  OpenDayApp
//
//  Created by Emmanuella Maduagwu on 13/11/2024.
//

import Foundation

    extension Date {
        func format(_ format: String) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            
            return formatter.string(from: self)
        }
    }

