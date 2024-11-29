//
//  DefaultLocationItem.swift
//  WeatherNow
//
//  Created by David Muñoz on 28/11/2024.
//

import Foundation
import Loadable
import Combine
import OSLog

public class DefaultLocationItem: Loadable, LocationItem, Equatable {
    
    public static func == (lhs: DefaultLocationItem, rhs: DefaultLocationItem) -> Bool {
        lhs.id == rhs.id
    }
    
    private let onSave: ((DefaultLocationItem) -> Void)?
    private let onSelect: ((DefaultLocationItem) -> Void)?
    private var raw: API.RAW.Location
    private let api: API.ClientsAPI.Weather?
    init(
        raw: API.RAW.Location,
        api: API.ClientsAPI.Weather? = nil,
        onSave: ((DefaultLocationItem) -> Void)? = nil,
        onSelect: ((DefaultLocationItem) -> Void)? = nil
    ) {
        self.api = api
        self.raw = raw
        self.onSave = onSave
        self.onSelect = onSelect
    }
    
    // MARK: - Properties
    
    public var selected: Bool = false {
        didSet {
            if oldValue != selected {
                notifyDataDidChanged()
            }
        }
    }
    public var weather: (any WeatherItem)?
    public var forecast: [(any WeatherItem)] = []
    public var id: String { raw.id }
    public var name: String { raw.name }
    public var latitude: Double { raw.latitude }
    public var longitude: Double { raw.longitude }
    public var createdAt: Date? { raw.savedAt }
    
    // MARK: - Overrides
    
    private let minutesTolerance: Double = 5*60
    override public var needsSync: Bool {
        if let weather {
            return weather.updatedAt.timeIntervalSinceNow.isLess(than: -minutesTolerance)
        } else {
            return true
        }
    }
    override public func doSync() {
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
                weather = BaseWeather(raw: weatherRaw)
                forecast = forecastRaw.list.map { ForecastWeather(raw: $0) }
                
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
    
    public func select() {
        guard !selected else { return }
        Logger.model.log(message: "Selected location \(raw.id)", tagging: className)
        selected = true
        onSelect?(self)
    }
    
    public func save() {
        onSave?(self)
    }
}
