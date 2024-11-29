//
//  API.RAW.Forecast.swift
//  WeatherNow
//
//  Created by David Muñoz on 27/11/2024.
//

import Foundation

public extension API.RAW {
    struct ForecastResponse: Decodable {
        let cod: String
        let message: Int
        let cnt: Int
        let list: [WeatherList]
        let city: City
    }
    
    struct MainWeatherData: Decodable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let pressure: Int
        let seaLevel: Int?
        let grndLevel: Int?
        let humidity: Int
        let tempKf: Double?
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feelsLike"
            case tempMin = "tempMin"
            case tempMax = "tempMax"
            case pressure
            case seaLevel = "seaLevel"
            case grndLevel = "grndLevel"
            case humidity
            case tempKf = "tempKf"
        }
    }

    struct WeatherList: Decodable {
        let dt: Int
        let main: MainWeatherData
        let weather: [Weather]
        let clouds: Clouds
        let wind: Wind?
        let visibility: Int?
        let pop: Double?
        let rain: Rain?
        let sys: Sys?
        let dtTxt: String
        
        enum CodingKeys: String, CodingKey {
            case dt, main, weather, clouds, wind, visibility, pop, rain, sys
            case dtTxt = "dtTxt"
        }
    }
    
    struct Weather: Decodable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct Clouds: Decodable {
        let all: Int
    }
    
    struct Wind: Decodable {
        let speed: Double
        let deg: Int
        let gust: Double
    }
    
    struct Rain: Decodable {
        let threeH: Double
        
        enum CodingKeys: String, CodingKey {
            case threeH = "3h"
        }
    }
    
    struct Sys: Decodable {
        let pod: String
    }
    
    struct City: Decodable {
        let id: Int
        let name: String
        let coord: Coordinates
        let country: String
        let population: Int
        let timezone: Int
        let sunrise: Int
        let sunset: Int
    }
}
