//
//  WeatherNowTests.swift
//  WeatherNowTests
//
//  Created by David Muñoz on 26/11/2024.
//

import Testing
@testable import WeatherNow

struct WeatherNowTests {
    let raw = Raws.weatherResponse

    var classToTest: BaseWeather!
    
    init() {
        classToTest = .init(raw: raw)
    }
    
    @Test("Test initialization of variables")
    func BaseWeatherCreation() async throws {
        #expect(classToTest.current == "description")
        #expect(classToTest.temperature == "23.0")
        #expect(classToTest.humidity == "123")
        #expect(classToTest.feelsLike == "23.0")
        #expect(classToTest.updatedAt != nil)
    }
}

// MARK: - Can be created in another file

class Raws {
    static let weatherResponse = API.RAW.WeatherResponse(
        coord: .init(lon: 10, lat: 20),
        weather: [.init(id: 1, main: "Clear", description: "description", icon: "10d")],
        base: "base", main: .init(temp: 23, feelsLike: 23, tempMin: 123, tempMax: 123, pressure: 12, seaLevel: nil, grndLevel: nil, humidity: 123, tempKf: 123),
        visibility: 123, wind: .init(speed: 123, deg: 32, gust: 123),
        clouds: .init(all: 23),
        dt: 123, sys: nil,
        timezone: 123, id: 123, name: "name", cod: 33
    )
    static let weatherData: API.RAW.MainWeatherData = .init(
        temp: 23, feelsLike: 22, tempMin: 0,
        tempMax: 1000, pressure: 123, seaLevel: nil,
        grndLevel: nil, humidity: 99, tempKf: nil
    )
    static let weather = API.RAW.Weather(id: 1, main: "Clear", description: "description", icon: "10d")
    
    static let forecastResponse = API.RAW.ForecastResponse(
        cod: "33", message: 123, cnt: 10, list: [
            .init(dt: 123, main: weatherData, weather: [weather], clouds: .init(all: 123), wind: nil, visibility: nil, pop: nil, rain: nil, sys: nil, dtTxt: "123")
        ],
        city: .init(
            id: 123, name: "123", coord: .init(lon: 33, lat: 22),
            country: "ar", population: 123, timezone: 123, sunrise: 123, sunset: 33
        )
    )
    
    static let locationResponse = API.RAW.Location(
        name: "name",
        localNames: nil, latitude: 23, longitude: 44, country: "asd"
    )
}
