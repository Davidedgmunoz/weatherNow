//
//  LocationRegistrationViewModel.swift
//  WeatherNow
//
//  Created by David Muñoz on 26/11/2024.
//

import Foundation
import Loadable
public extension LocationRegistration {
    final class ViewModel: LoadableProxy, ViewModelProtocol {
        private let model: LocationProtocol
        init(model: LocationProtocol) {
            self.model = model
            super.init()
            loadable = model
        }
        
        public var cityName: String?
        public var latitude: String?
        public var longitude: String?
        
        public var currentLocationFound: LocationItem?
        public func searchLocation(forLat lat: Double, andLon lon: Double) {
            Task {
                if let location = await model.findLocation(latitude: lat, longitude: lon) {
                    currentLocationFound = location
                    cityName = location.name
                    latitude = String(location.latitude)
                    longitude = String(location.longitude)
                    notifyDataDidChanged()
                }
            }
        }
        
        public func save() {
            guard let currentLocationFound else { return }
            currentLocationFound.save()
        }
    }
}
