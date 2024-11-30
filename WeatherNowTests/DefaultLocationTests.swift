//
//  DefaultLocationTests.swift
//  WeatherNowTests
//
//  Created by David Muñoz on 30/11/2024.
//

import Testing
import Loadable
@testable import WeatherNow
import Foundation

struct DefaultLocationTests {
    let mockAPI = MockAPI()
    let mockNotificationManager = MockNotificationManager()
    let mockPersistenceManager = MockLocationPersistenceManager()
    let classUnderTest: Location!
    
    init() {
        classUnderTest = Location(
            api: mockAPI,
            notificationManager: mockNotificationManager,
            persistenceManager: mockPersistenceManager
        )
    }
    
    @Test("When first run and the user does not have any location saved, the location needs to be synced")
    func locationNeedsSyncWhenNoItem() async throws {
        // We start we never tried to get the items
        #expect(mockPersistenceManager.items.isEmpty)
        #expect(classUnderTest.needsSync)

        // After adding one item we shouldn't need to sync and should have 1 items
        classUnderTest.syncIfNeeded()
        mockPersistenceManager.save(Raws.locationResponse)

        #expect(!classUnderTest.needsSync)
        #expect(classUnderTest.locations.count == 1)
    }
}


// MARK: - Mocks
class MockNotificationManager: NotificationsManager {
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
    }
    
    func scheduleNotification(title: String, body: String, at date: Date) {
    }
    
    func scheduleImmediateNotification(title: String, body: String) {
    }
    
    func cancelAllNotifications() {
    }
    
    func cancelNotification(withIdentifier identifier: String) {
    }
}

class MockLocationPersistenceManager: TestLoadable, LocationPersistenceManager {
    func save(_ location: WeatherNow.API.RAW.Location) {
        items.append(location)
        state = .didSuccess
        notifyDataDidChanged()
    }
    var items: [API.RAW.Location] = []
}

class MockAPI: API_ClientsAPI_Location & API_ClientsAPI_Weather {
    func getLocation(fromLat lat: Double, andLon lon: Double) async throws -> [API.RAW.Location] {
        return [Raws.locationResponse]
    }
    
    func getWeather(forLat lat: Double, andLon lon: Double) async throws -> API.RAW.WeatherResponse {
        return Raws.weatherResponse
    }
    
    func getForecast(forLat lat: Double, andLon lon: Double) async throws -> API.RAW.ForecastResponse {
        return Raws.forecastResponse
    }
    
}