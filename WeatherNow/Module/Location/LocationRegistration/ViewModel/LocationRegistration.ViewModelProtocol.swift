//
//  LocationViewModel.swift
//  WeatherNow
//
//  Created by David Muñoz on 26/11/2024.
//

import Combine
import Foundation
import Loadable

public extension LocationRegistration {
    enum Action {
        case didAddLocation
        case didFailToAddLocation
    }

    protocol ViewModelProtocol: LoadableProxyProtocol {
        var actionPublisher: AnyPublisher<Action, Never> { get }
        var cityName: String? { get }
        var latitude: String? { get }
        var longitude: String? { get }
        
        func searchLocation(forLat lat: Double, andLon lon: Double)
        
        func save()
    }
}
