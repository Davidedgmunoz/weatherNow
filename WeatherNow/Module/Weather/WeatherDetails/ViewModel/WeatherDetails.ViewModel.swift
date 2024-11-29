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
        case calendarEventAdded
        case calendarEventFailed
    }

    protocol ViewModel: LoadableProxyProtocol {
        var headerViewModel: HeaderViewModel? { get }
        var forecastItems: [ForecastItemViewModel] { get }
        var actionPublisher: AnyPublisher<Action, Never> { get }
        
        func openList()
        func setEvents()
    }
    
    // MARK: - Default
    final class DefaultViewModel: LoadableProxy, ViewModel {
        let model: LocationProtocol
        let locationManager: LocationManager
        private let calendarManager: CalendarManager
        init(
            model: LocationProtocol,
            locationManager: LocationManager,
            calendarManager: CalendarManager
        ) {
            self.calendarManager = calendarManager
            self.locationManager = locationManager
            self.model = model
            super.init()
            
            handleLocations()
            updateLocation()
        }

        public var actionPublisher: AnyPublisher<Action, Never> {
            actionSubject.eraseToAnyPublisher()
        }
        let actionSubject = PassthroughSubject<Action, Never>()

        public var forecastItems: [any ForecastItemViewModel] = []
        public var headerViewModel: (any HeaderViewModel)?

        private var cancellables: Set<AnyCancellable> = []
        private var currentLocation: LocationItem?
        
        // MARK: - Overrides
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

        // MARK: - Public
        
        public func openList() {
            let viewModel = LocationList.DefaultViewModel(model: model)
            actionSubject.send(.openList(viewModel))
        }
        
        public func setEvents() {
            calendarManager.addCalendarEvents()
                .sink { [weak self] completion in
                    switch completion {
                    case .failure:
                        self?.actionSubject.send(.calendarEventAdded)
                    default:
                        break
                    }
                } receiveValue: { [weak self] didSucceed in
                    self?.actionSubject.send(didSucceed ? .calendarEventAdded : .calendarEventFailed)
                }.store(in: &cancellables)
        }

        // MARK: - Private
        
        private func handleLocations() {
            model.objectWillChange.sink { [weak self] in
                self?.updateLocation()
            }.store(in: &cancellables)
            locationManager.locationPublisher
                .sink { [weak self] in
                    self?.model.addUsersLocation(
                        latitude: $0.coordinate.latitude,
                        longitude: $0.coordinate.longitude
                    )
                }.store(in: &cancellables)
            if locationManager.status == .notDetermined {
                locationManager.requestLocationPermission()
            } else if locationManager.status == .authorizedAlways || locationManager.status == .authorizedWhenInUse {
                locationManager.requestLocation()
            }

        }
        private func updateLocation() {
            if let selectedLocation = model.locations.first(where: { $0.selected }) {
                Logger.model.log(message: "Selected location: \(selectedLocation)" , tagging: className)
                currentLocation = selectedLocation
            } else if let firstLocation = model.locations.first {
                currentLocation = firstLocation
            }
            
            if let currentLocation {
                self.loadable = currentLocation
                currentLocation.syncIfNeeded()
            }
        }
        
        private func populate() {
            guard let currentLocation else { return }
            headerViewModel = DefaultHeaderViewModel(location: currentLocation)
            forecastItems = currentLocation.forecast.map { DefaultForecastItemViewModel(model: $0)}
        }
    }
}
