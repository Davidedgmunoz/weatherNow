//
//  LocationViewModel.swift
//  WeatherNow
//
//  Created by David Muñoz on 26/11/2024.
//

import Foundation
import Loadable

public extension LocationRegistration {
    protocol ViewModelProtocol: LoadableProxyProtocol {
        var cityName: String? { get }
        var latitude: String? { get }
        var longitude: String? { get }
        
        func searchLocation(forLat lat: Double, andLon lon: Double)
        
        func save()
    }
}
