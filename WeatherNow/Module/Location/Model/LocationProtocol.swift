//
//  Location.swift
//  WeatherNow
//
//  Created by David Muñoz on 26/11/2024.
//

import Combine
import Foundation
import Loadable
import OSLog

public protocol LocationProtocol: LoadableProtocol {
    var locations: [LocationItem] { get }
    
    func findLocation(latitude: Double, longitude: Double) async -> LocationItem?
    func addUsersLocation(latitude: Double, longitude: Double)
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
    var isUserLocation: Bool { get }
    
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
