//
//  ForecastWeather.swift
//  WeatherNow
//
//  Created by David Muñoz on 28/11/2024.
//

import Foundation
public class ForecastWeather: WeatherItem {
    public static func == (lhs: ForecastWeather, rhs: ForecastWeather) -> Bool {
        lhs.raw.weather.first?.id == rhs.raw.weather.first?.id
    }

    public var current: String  { raw.weather.first?.description ?? "" }
    public var temperature: String = ""
    public var humidity: String = ""
    public var feelsLike: String = ""
    public var iconUrl: String {
        guard let icon = raw.weather.first?.icon
        else {
            // TODO: - Add fallback
            return "https://openweathermap.org/img/wn/10d@2x.png"
        }
        return "https://openweathermap.org/img/wn/\(icon)@2x.png"
    }
    public var description: String? { raw.weather.first?.description  }
    public var date: Date { Date(timeIntervalSince1970: TimeInterval(raw.dt)) }
    public var updatedAt: Date = .now
    public var maxTemperature: String { "\(raw.main.tempMax)" }
    public var minTemperature: String { "\(raw.main.tempMin)" }
    
    let raw: API.RAW.WeatherList
    public init(raw: API.RAW.WeatherList) {
        self.raw = raw
    }
}
