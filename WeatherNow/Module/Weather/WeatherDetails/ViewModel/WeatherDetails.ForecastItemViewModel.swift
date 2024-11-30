//
//  WeatherDetails.ForecastItemViewModel.swift
//  WeatherNow
//
//  Created by David Muñoz on 27/11/2024.
//

import Foundation

public extension WeatherDetails {
    protocol ForecastItemViewModel {
        var date: String { get }
        var iconURL: URL { get }
        var temperatures: String { get }
        var weatherDescription: String { get }
    }
    
    // MARK: - Default
    
    final class DefaultForecastItemViewModel: ForecastItemViewModel {
        public var date: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E MMM d: HH:mm"
            return dateFormatter.string(from: model.date)
        }
        public lazy var iconURL: URL = .init(string: model.iconUrl)!
        public var temperatures: String {
            .init(format: "forecastItem.temperaturesFormat".localized,
                  model.maxTemperature, model.minTemperature
            )
        }
        public var weatherDescription: String { model.description ?? ""}
        let model: any WeatherItem
        init(model: any WeatherItem) {
            self.model = model
            
        }
    }
}
