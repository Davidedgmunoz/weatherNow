//
//  ClientsAPI.swift
//  Project
//
//  Created by David Muñoz.
//

import Foundation

extension API {
    /// Clients API, used for all the information displayed in the user's Profile.
    /// (Unlike other "APIs" I've added `API` suffix here to separate from `API.Client`.)
    public typealias ClientsAPI = API_ClientsAPI
}

public protocol API_ClientsAPI:
    API_ClientsAPI_Weather, API_ClientsAPI_Location {
    /// "Catalogue" part of the Clients API. This is where different static data can be retrieved.
    typealias Weather = API_ClientsAPI_Weather
    typealias Location = API_ClientsAPI_Location

}

public protocol API_ClientsAPI_Weather: AnyObject {
    func getWeather(forLat lat: Double, andLon lon: Double) async throws -> API.RAW.WeatherResponse
    func getForecast(forLat lat: Double, andLon lon: Double) async throws -> API.RAW.ForecastResponse
}

public protocol API_ClientsAPI_Location: AnyObject {
    func getLocation(fromLat lat: Double, andLon lon: Double) async throws -> [API.RAW.Location]
}



