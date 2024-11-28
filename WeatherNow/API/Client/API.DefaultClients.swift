//
//  API.DefaultClientsAPI.swift
//  Project
//
//  Created by David Muñoz on 05/06/2021.
//

import Foundation
import Combine

extension API {
 
    public final class DefaultClient: API.ClientsAPI {

        private let env: Environment
        private let httpClient: API.HTTPClient

        public init(
            environment: Environment,
            httpClient: API.HTTPClient? = nil
        ) {
            self.env = environment
            self.httpClient = httpClient ?? API.DefaultHTTPClient()
        }        
        
        private func urlWithPath(_ path: String) -> URL {
            
            let resourceUrl = env.clientsAPI.baseURL
            return URL(string: path, relativeTo: resourceUrl)!

        }
        
        // MARK: - Weather
        
        public func getWeather(forLat lat: Double, andLon lon: Double) async throws -> API.RAW.WeatherResponse {
            return try await httpClient.get(
                url: urlWithPath("data/2.5/weather"),
                queryParams: [
                    "lat":"\(lat)",
                    "lon":"\(lon)",
                    "units": "metric",
                    "appid": env.clientsAPI.apiKey
                ],
                headers: ["":""],
                responseType: API.RAW.WeatherResponse.self
            ).async()
        }
        
        public func getForecast(forLat lat: Double, andLon lon: Double) async throws -> API.RAW.ForecastResponse {
            return try await httpClient.get(
                url: urlWithPath("data/2.5/forecast"),
                queryParams: [
                    "lat":"\(lat)",
                    "lon":"\(lon)",
                    "units": "metric",
                    "cnt": "10",
                    "appid": env.clientsAPI.apiKey
                ],
                headers: ["":""],
                responseType: API.RAW.ForecastResponse.self
            ).async()
        }

        // MARK: - Location

        public func getLocation(fromLat lat: Double, andLon lon: Double) async throws -> [API.RAW.Location] {
            return try await httpClient.get(
                url: urlWithPath("geo/1.0/revers"),
                queryParams: [
                    "lat":"\(lat)",
                    "lon":"\(lon)",
                    "limit": "1",
                    "appid": env.clientsAPI.apiKey
                ],
                headers: ["":""],
                responseType: [API.RAW.Location].self
            ).async()
        }
    }
}

// MARK: -

enum AsyncError: Error {
    case finishedWithoutValue
}

extension AnyPublisher {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            cancellable = first()
                .sink { result in
                    switch result {
                    case .finished:
                        if finishedWithoutValue {
                            continuation.resume(throwing: AsyncError.finishedWithoutValue)
                        }
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    finishedWithoutValue = false
                    continuation.resume(with: .success(value))
                }
        }
    }
}

