//
//  LocationList.ViewModel.swift
//  WeatherNow
//
//  Created by David Muñoz on 26/11/2024.
//

import Combine
import Foundation
import Loadable
import OSLog

public extension LocationList {
    enum Actions {
        case openRegistration(LocationRegistration.ViewModelProtocol)
    }
    
    protocol ViewModel: LoadableProxyProtocol {
        var items: [ViewModelItem] { get }
        var actionsPublisher: AnyPublisher<Actions, Never> { get }
        
        func openRegistration()
    }
    
    protocol ViewModelItem: LoadableProxyProtocol {
        var name: String { get }
        var temperature: String { get }
        var realFeel: String { get }
        var weatherDescription: String { get }
        var weatherImage: String? { get }
        var isSelected: Bool { get }
        var isUsersLocation: Bool { get }
        
        func select()
    }
    
    // MARK: - Defaults
    
    final class DefaultViewModel: LoadableProxy, ViewModel {
        
        private let model: LocationProtocol
        init(model: LocationProtocol) {
            self.model = model
            super.init()
            loadable = model
            if !model.needsSync { populate() }
        }
        public var actionsPublisher: AnyPublisher<LocationList.Actions, Never> {
            actionSubject.eraseToAnyPublisher()
        }
        private let actionSubject: PassthroughSubject<LocationList.Actions, Never> = .init()
        
        public func openRegistration() {
            actionSubject.send(.openRegistration(LocationRegistration.ViewModel(model: model)))
        }

        public override func proxyDidChange() {
            guard model.locations.count != items.count else { return }
            populate()
        }

        func populate() {
            items = model.locations.map { _ItemViewModel(model: $0) }
        }
        public var items: [ViewModelItem] = []
        
        fileprivate class _ItemViewModel: LoadableProxy, ViewModelItem {
            var realFeel: String = ""
            var weatherDescription: String = "--"
            lazy var name: String = model.name
            var temperature: String = "--"
            var weatherImage: String?
            var icon: String?
            let model: LocationItem
            init(model: LocationItem) {
                self.model = model
                super.init()
                loadable = model
                update()
            }
            var isSelected: Bool { model.selected }
            var isUsersLocation: Bool { model.isUserLocation }

            func select() {
                model.select()
            }

            override func proxyDidChange() {
                update()
            }
            private func update() {
                guard let weather = model.weather else { return }
                temperature = String(format: "locationItem.temperature.format".localized, weather.temperature)
                weatherImage = weather.iconUrl
                realFeel = String(format: "locationItem.feelsLike.format".localized, weather.feelsLike)
                weatherDescription = String(format: "locationItem.weatherDescription.format".localized, weather.current.description)

            }
        }
    }
}
