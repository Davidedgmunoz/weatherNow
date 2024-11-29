//
//  Models.swift
//  WeatherNow
//
//  Created by David Muñoz on 26/11/2024.
//

import Foundation

public protocol Models: AnyObject {
    var location: LocationProtocol { get }
    var persistenceManger: LocationPersistenceManager { get }
    var locationManager: LocationManager { get }
    var calendarManager: CalendarManager { get }
}

// MARK: - Defaults

public class DefaultModels: Models {
    
    private let api: API.ClientsAPI
    init(api: API.ClientsAPI) {
        self.api = api
    }
    public var persistenceManger: any LocationPersistenceManager = UserDefaultsPersistenceManager()

    public lazy var location: any LocationProtocol = { Location(api: api, persistenceManager: persistenceManger) }()
   
    public lazy var locationManager: any LocationManager = { DefaultLocationManager() }()
    public lazy var calendarManager: any CalendarManager = { DefaultCalendarManager() }()

}

// MARK: - Core

internal final class Core {
    public static private(set) var shared: Core!
    public var models: Models!
    public init() {
        
        // Here we can add a tweak utility or change it manually to use a different ambient or model
        let appEnvironment: API.Environment = {
            #if DEBUG
                .qa
            #else
                .prod
            #endif
        }()
        
        models = DefaultModels(api: API.DefaultClient(environment: appEnvironment))
        
        assert(Self.shared == nil, "Trying to init \(type(of: self)) again?")
        Self.shared = self

    }
}
