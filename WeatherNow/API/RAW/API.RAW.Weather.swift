//
//  API.RAW.WeatherResponse.swift
//  WeatherResponse
//
//  Created by David Muñoz on 26/10/2024.
//

import Foundation

public extension API.RAW {
    struct Coordinates: Decodable {
        let lon: Double
        let lat: Double
        
        enum CodingKeys: String, CodingKey {
            case lon
            case lat
        }
    }
    
    struct WeatherResponse: Decodable {
        
        struct Weather: Decodable {
            let id: Int
            let main: String
            let description: String
            let icon: String
            
            enum CodingKeys: String, CodingKey {
                case id
                case main
                case description
                case icon
            }
        }
        
        struct Wind: Decodable {
            let speed: Double
            let deg: Int
            let gust: Double?
            
            enum CodingKeys: String, CodingKey {
                case speed
                case deg
                case gust
            }
        }
        
        struct Clouds: Decodable {
            let all: Int
            
            enum CodingKeys: String, CodingKey {
                case all
            }
        }
        
        struct Sys: Decodable {
            let country: String
            let sunrise: Int
            let sunset: Int
            
            enum CodingKeys: String, CodingKey {
                case country
                case sunrise
                case sunset
            }
        }
        
        let coord: Coordinates
        let weather: [Weather]
        let base: String
        let main: MainWeatherData
        let visibility: Int
        let wind: Wind
        let clouds: Clouds
        let dt: Int
        let sys: Sys
        let timezone: Int
        let id: Int
        let name: String
        let cod: Int
        
        enum CodingKeys: String, CodingKey {
            case coord
            case weather
            case base
            case main
            case visibility
            case wind
            case clouds
            case dt
            case sys
            case timezone
            case id
            case name
            case cod
        }
    }
}
