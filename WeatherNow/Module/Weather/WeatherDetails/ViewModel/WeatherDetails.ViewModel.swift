//
//  WeatherDetails.ViewModel.swift
//  WeatherNow
//
//  Created by David Muñoz on 27/11/2024.
//

import Foundation
import Combine
import Loadable
import OSLog

public extension WeatherDetails {
    protocol ViewModel: LoadableProxyProtocol {
        var headerViewModel: HeaderViewModel? { get }
        var forecastItems: [ForecastItemViewModel] { get }
        
        func openList()
    }
    
    // MARK: - Default
    final class DefaultViewModel: LoadableProxy, ViewModel {
        let model: LocationProtocol
        init(model: LocationProtocol) {
            self.model = model
            super.init()
            updateLocation()
        }

        public var forecastItems: [any ForecastItemViewModel] = []
        public var headerViewModel: (any HeaderViewModel)?

        private var locationCancellable: AnyCancellable?
        private var currentLocation: LocationItem?
        
        public override func proxyDidChange() {
            populate()
        }
        
        public override func doSync() {
            updateLocation()
            super.doSync()
        }
        // MARK: - Private
        
        private func updateLocation() {
            if let selectedLocation = model.locations.first(where: { $0.selected }) {
                Logger.model.log(message: "Selected location: \(selectedLocation)" , tagging: className)
                currentLocation = selectedLocation
            } else if let firstLocation = model.locations.first {
                currentLocation = firstLocation
            } else {
                // TODO: - Add gps getting! :P
            }
            
            if let currentLocation {
                self.loadable = currentLocation
                currentLocation.syncIfNeeded()
            } else {
                // Notify no location was able to fetch
            }
        }
        
        private func populate() {
            guard let currentLocation else { return }
            headerViewModel = DefaultHeaderViewModel(location: currentLocation)
            forecastItems = currentLocation.forecast.map { DefaultForecastItemViewModel(model: $0)}
        }
        
        // MARK: - Public
        
        public func openList() {
        }
    }
}
