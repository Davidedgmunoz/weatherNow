//
//  WeatherDetails.HeaderViewModel.swift
//  WeatherNow
//
//  Created by David Muñoz on 27/11/2024.
//

import Loadable
import Foundation

public extension WeatherDetails {
    protocol HeaderViewModel: LoadableProxyProtocol {
        var title: String { get }
        var updateDate: String { get }
        var iconURL: URL? { get }
        var temperature: String { get }
        var description: String { get }
        var isUserLocation: Bool { get }

        var windSpeed: String { get }
        var humidity: String { get }
        var visibility: String { get }
    }
    
    final class DefaultHeaderViewModel: LoadableProxy, HeaderViewModel {
        public var title: String { location.name }
        public var updateDate: String = "--"
        public var iconURL: URL?
        public var temperature: String = "--"
        public var description: String = "--"
        public var windSpeed: String = "--"
        public var humidity: String = "--"
        public var visibility: String = "--"
        public var isUserLocation: Bool { location.isUserLocation}
        let location: LocationItem
        init(location: LocationItem) {
            self.location = location
            super.init()
            loadable = location
            
            // Calling update, we might have already updated this values from before!
            update()
        }
        
        public override func proxyDidChange() {
            guard
                loadable.state != .syncing,
                loadable.state != .didFail
            else {
                return
            }
            update()
        }
        
        private func update() {
            guard let weather = location.weather else {
                return
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, HH:mm"
            updateDate = "Last update:" + dateFormatter.string(from: weather.updatedAt)
            temperature = weather.temperature + "°C"
            description = String(
                format: "weatherDetails.descriptionFormat".localized,
                weather.feelsLike, weather.description?.capitalizeFirstLetter() ?? "", weather.humidity
            )
            
            guard
                let icon = location.weather?.iconUrl,
                let url = URL(string: icon)
            else { return }
            iconURL = url

        }
    }
}

extension String {
    func capitalizeFirstLetter() -> String {
        guard let first = self.first else { return self }
        return first.uppercased() + self.dropFirst()
    }
}
