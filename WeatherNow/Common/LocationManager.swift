//
//  UserLocationManager.swift
//  WeatherNow
//
//  Created by David Muñoz on 28/11/2024.
//

import Combine
import CoreLocation
import Loadable

public protocol LocationManager: AnyObject {
    var status: CLAuthorizationStatus { get }
    var lastLocation: CLLocation? { get }
    var locationPublisher: AnyPublisher<CLLocation, Never> { get }
    
    func requestLocationPermission()
    func requestLocation()
}

public final class DefaultLocationManager: NSObject, LocationManager, CLLocationManagerDelegate {
    public var status: CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
    
    public var lastLocation: CLLocation? {
        didSet {
            if let lastLocation {
                locationSubject.send(lastLocation)
            }
        }
    }
    
    private let locationSubject: PassthroughSubject<CLLocation, Never> = .init()
    public var locationPublisher: AnyPublisher<CLLocation, Never> {
        locationSubject.eraseToAnyPublisher()
    }
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    public func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func requestLocation() {
        locationManager.requestLocation()
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    public func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.last {
            lastLocation = location
            
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
         switch manager.authorizationStatus {
         case .authorizedWhenInUse, .authorizedAlways:
             requestLocation()
         default:
             break
        }
    }
}
