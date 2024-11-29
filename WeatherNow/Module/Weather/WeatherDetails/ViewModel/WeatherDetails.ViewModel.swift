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
    enum Action {
        case openList(LocationList.ViewModel)
        case presentNoLocationAddedView
    }

    protocol ViewModel: LoadableProxyProtocol {
        var headerViewModel: HeaderViewModel? { get }
        var forecastItems: [ForecastItemViewModel] { get }
        var actionPublisher: AnyPublisher<Action, Never> { get }
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
        public var actionPublisher: AnyPublisher<Action, Never> {
            actionSubject.eraseToAnyPublisher()
        }
        let actionSubject = PassthroughSubject<Action, Never>()

        public var forecastItems: [any ForecastItemViewModel] = []
        public var headerViewModel: (any HeaderViewModel)?

        private var locationCancellable: AnyCancellable?
        private var currentLocation: LocationItem?
        
        public override func proxyDidChange() {
            populate()
        }
        
        public override func doSync() {
            updateLocation()
            // For this case we have an special case that shouldn't happening
            // but for the logic that I decided to present,
            // we must verify if we don't have any location yet!
            guard currentLocation != nil else {
                actionSubject.send(.presentNoLocationAddedView)
                return
            }
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
            let viewModel = LocationList.DefaultViewModel(model: model)
            actionSubject.send(.openList(viewModel))
        }
    }
}
