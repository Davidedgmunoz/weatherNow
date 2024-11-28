//
//  Location.swift
//  WeatherNow
//
//  Created by David Muñoz on 26/11/2024.
//

import Foundation
import Loadable
import Combine
import OSLog

public protocol LocationProtocol: LoadableProtocol {
    var locations: [LocationItem] { get }
    
    func findLocation(latitude: Double, longitude: Double) async -> LocationItem?
}

public protocol LocationItem: LoadableProtocol {
    var id: String { get }
    var name: String { get }
    var latitude: Double { get }
    var longitude: Double { get }
    var createdAt: Date? { get }
    var weather: WeatherItem? { get }
    var forecast: [WeatherItem] { get }
    var selected: Bool { get }
    
    func select()
    func save()
}

public protocol WeatherItem: AnyObject {
    var current: String { get }
    var temperature: String { get }
    var maxTemperature: String { get }
    var minTemperature: String { get }
    var humidity: String { get }
    var feelsLike: String { get }
    var date: Date { get }
    var iconUrl: String { get }
    var description: String? { get }
    
    var updatedAt: Date { get }
}

// MARK: - Default

public final class Location: Loadable, LocationProtocol {
    private let api: API.ClientsAPI.Location&API.ClientsAPI.Weather
    private let persistenceManager: LocationPersistenceManager
    init(
        api: API.ClientsAPI.Location&API.ClientsAPI.Weather,
        persistenceManager: LocationPersistenceManager
    ) {
        self.persistenceManager = persistenceManager
        self.api = api
    }

    public var locations: [any LocationItem] { _locations }
    private var _locations: [_Item] = []
    
    fileprivate var selectedItem: _Item? {
        willSet {
            selectedItem?.unselect()
        }
    }

    // we just load locations when they are empty
    // otherwise we can handle them in memory
    public override var needsSync: Bool { persistenceManager.items.isEmpty }

    private var cancellable: AnyCancellable?
    public override func doSync() {
        startSyncing()
        cancellable = persistenceManager.objectWillChange.sink {
            [weak self] in self?.locationsUpdated()
        }
        persistenceManager.syncIfNeeded()
        locationsUpdated()
    }
    
    private lazy var onSelect: ((_Item) -> Void)? = { [weak self] item in
        self?.selectedItem = item
    }

    private func locationsUpdated() {
        guard persistenceManager.state == .didSuccess else { return }
        _locations = persistenceManager.items.map { _Item(raw: $0, api: api, onSelect: onSelect) }
        
        if let selected = selectedItem,
            let matchingItem = _locations.first(where: { $0.id == selected.id }) {
            matchingItem.select()
        } else if let firstItem = _locations.first {
            firstItem.select()
        }

        state = .didSuccess
    }
    
    public func findLocation(latitude: Double, longitude: Double) async -> LocationItem? {
        guard state != .syncing else { return nil }
        startSyncing()
        let result = try? await api.getLocation(fromLat: latitude, andLon: longitude)
        state = .idle
        guard var raw = result?.first else { return nil }
        return _Item(
            raw: raw,
            api: api,
            onSave: { [weak self] item in
                raw.updateSavedAt()
                self?._locations.append(item)
                self?.persistenceManager.save(raw)
            },
            onSelect: onSelect
        )
    }
        
    // MARK: - Item
    
    fileprivate class _Item: Loadable, LocationItem {
        private let onSave: ((_Item) -> Void)?
        private let onSelect: ((_Item) -> Void)?
        var raw: API.RAW.Location
        let api: API.ClientsAPI.Weather?
        init(
            raw: API.RAW.Location,
            api: API.ClientsAPI.Weather? = nil,
            onSave: ((_Item) -> Void)? = nil,
            onSelect: ((_Item) -> Void)? = nil
        ) {
            self.api = api
            self.raw = raw
            self.onSave = onSave
            self.onSelect = onSelect
        }
        
        // MARK: - Properties
        
        var selected: Bool = false {
            didSet {
                if oldValue != selected {
                    notifyDataDidChanged()
                }
            }
        }
        var weather: (any WeatherItem)?
        var forecast: [(any WeatherItem)] = []
        var id: String { raw.id }
        var name: String { raw.name }
        var latitude: Double { raw.latitude }
        var longitude: Double { raw.longitude }
        var createdAt: Date? { raw.savedAt }

        // MARK: - Overrides
        
        override var needsSync: Bool { weather == nil }
        override func doSync() {
            Logger.model.log(message: "Syncing location \(raw.id)", tagging: className)
            guard state != .syncing else { return }
            guard let api else {
                assertionFailure("Trying to sync location's weather without api? not intended?")
                return
            }
            startSyncing()
            Task {
                do {
                    let weatherRaw = try await api.getWeather(forLat: raw.latitude, andLon: raw.longitude)
                    let forecastRaw = try await api.getForecast(forLat: raw.latitude, andLon: raw.longitude)
                    Logger.model.log(
                        message: "did return with \(weatherRaw.name) weather",
                        tagging: className
                    )
                    Logger.model.log(
                        message: "and \(forecastRaw.list.count) items in forecast",
                        tagging: className
                    )
                    weather = _Weather(raw: weatherRaw)
                    forecast = forecastRaw.list.map { _ForecastWeather(raw: $0) }
                    
                    state = .didSuccess
                } catch let error {
                    print(error)
                    state = .didFail
                }
            }
        }

        internal func unselect() {
            selected = false
        }

        // MARK: - Publics
        
        func select() {
            Logger.model.log(message: "Selected location \(raw.id)", tagging: className)
            selected = true
            onSelect?(self)
        }

        func save() {
            onSave?(self)
        }
    }
    
    // MARK: - Regular
    
    fileprivate class _Weather: WeatherItem {
        
        var current: String { raw.weather.first?.description ?? "" }
        var temperature: String { "\(raw.main.temp)" }
        var humidity: String { "\(raw.main.humidity)" }
        var feelsLike: String { "\(raw.main.feelsLike)" }
        var description: String? { raw.weather.first?.description }
        var date: Date { .now }
        var updatedAt: Date
        var iconUrl: String {
            guard let icon = raw.weather.first?.icon
            else {
                // TODO: - Add fallback
                return "https://openweathermap.org/img/wn/10d@2x.png"
            }
            return "https://openweathermap.org/img/wn/\(icon)@2x.png"
        }
        var maxTemperature: String { "\(raw.main.tempMax)" }
        var minTemperature: String { "\(raw.main.tempMin)" }

        let raw: API.RAW.WeatherResponse
        init(raw: API.RAW.WeatherResponse) {
            self.raw = raw
            updatedAt = Date()
        }
    }
    
    // MARK: - Forecast

    fileprivate class _ForecastWeather: WeatherItem {
        var current: String = ""
        var temperature: String = ""
        var humidity: String = ""
        var feelsLike: String = ""
        var iconUrl: String {
            guard let icon = raw.weather.first?.icon
            else {
                // TODO: - Add fallback
                return "https://openweathermap.org/img/wn/10d@2x.png"
            }
            return "https://openweathermap.org/img/wn/\(icon)@2x.png"
        }
        var description: String? { raw.weather.first?.description  }
        var date: Date { Date(timeIntervalSince1970: TimeInterval(raw.dt)) }
        var updatedAt: Date = .now
        var maxTemperature: String { "\(raw.main.tempMax)" }
        var minTemperature: String { "\(raw.main.tempMin)" }

        let raw: API.RAW.WeatherList
        init(raw: API.RAW.WeatherList) {
            self.raw = raw
        }
    }
}
