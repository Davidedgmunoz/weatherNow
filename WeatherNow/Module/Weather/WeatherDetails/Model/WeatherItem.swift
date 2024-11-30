//
//  WeatherItem.swift
//  WeatherNow
//
//  Created by David Muñoz on 28/11/2024.
//

import Foundation

public class BaseWeather: WeatherItem {
    public static func == (lhs: BaseWeather, rhs: BaseWeather) -> Bool {
        lhs.raw.weather.first?.id == rhs.raw.weather.first?.id
    }
    public var current: String { raw.weather.first?.description ?? "" }
    public var temperature: String { "\(raw.main.temp)" }
    public var humidity: String { "\(raw.main.humidity)" }
    public var feelsLike: String { "\(raw.main.feelsLike)" }
    public var description: String? { raw.weather.first?.description }
    public var date: Date { .now }
    public var updatedAt: Date
    public var iconUrl: String {
        guard let icon = raw.weather.first?.icon
        else {
            // TODO: - Add fallback
            return "https://openweathermap.org/img/wn/10d@2x.png"
        }
        return "https://openweathermap.org/img/wn/\(icon)@2x.png"
    }
    public var maxTemperature: String { "\(raw.main.tempMax)" }
    public var minTemperature: String { "\(raw.main.tempMin)" }
    
    let raw: API.RAW.WeatherResponse
    init(raw: API.RAW.WeatherResponse) {
        self.raw = raw
        updatedAt = Date()
    }
}
