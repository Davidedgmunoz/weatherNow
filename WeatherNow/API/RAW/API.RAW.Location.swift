//
//  API.RAW.Location.swift
//  WeatherNow
//
//  Created by David Muñoz on 26/11/2024.
//

import Foundation
public extension API.RAW {
    
    struct Location: Codable {
        var id: String { "\(name)\(latitude)\(longitude)" }
        let name: String
        let localNames: [String: String]?
        let latitude: Double
        let longitude: Double
        let country: String

        // This are cread at saving time
        var savedAt: Date?
        
        enum CodingKeys: String, CodingKey {
            case name
            case localNames = "localNames"
            case latitude = "lat"
            case longitude = "lon"
            case country
            case savedAt
        }
        
        mutating func updateSavedAt() {
            savedAt = .now
        }
    }
}
