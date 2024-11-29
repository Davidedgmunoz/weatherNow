//
//  PersistenceManager.swift
//  WeatherNow
//
//  Created by David Muñoz on 27/11/2024.
//

import Foundation
import Loadable
import OSLog

public protocol LocationPersistenceManager: LoadableProtocol {
    func save(_ location: API.RAW.Location)
    var items: [API.RAW.Location] { get }
}

// Doing UserDefaults, since it is easier and quicker,
// but in other cases I would do CoreData Or Room to a more robust solution
// for now, this should do the trick (=
public final class UserDefaultsPersistenceManager: Loadable,  LocationPersistenceManager {
    private let userDefaults: UserDefaults
    public var items: [API.RAW.Location] = []
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    private let key: String = "weather_now_locations"
    
    public func save(_ location: API.RAW.Location) {
        // Special treatment, always the first
        if location.isUsersLocation ?? false {
            if items.first?.isUsersLocation ?? false {
                items.removeFirst()
            }
            items.insert(location, at: 0)
        } else {
            items.append(location)
        }

        let jsonData = try? JSONEncoder().encode(items)
        Logger.model.log(
            message: "Saving data: \(String(data: jsonData!, encoding: .utf8)!)",
            tagging: className
        )
        userDefaults.set(jsonData, forKey: key)
    }
    
    public override func doSync() {
        startSyncing()
        items = load()
        state = .didSuccess
    }

    private func load() -> [API.RAW.Location] {
        let data = userDefaults.data(forKey: key)
        Logger.model.log(message: "Retrieving data", tagging: className)
        guard let data else { return [] }
        Logger.model.log(message: "Obtained data", tagging: className)
        do {
            return try JSONDecoder().decode([API.RAW.Location].self, from: data)
        } catch {
            return []
        }
    }
}
