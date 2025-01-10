//
//  APIService.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 10/01/2025.
//

import Foundation

protocol APIServiceProtocol {
    func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> Current
    func fetchWeatherForcast(latitude: Double, longitude: Double) async throws -> [Current]
}

class APIService {
    let apiKey = "77233f733b24946fbf525301e1943a2b"
    let openWeatherAPI = "https://api.openweathermap.org/"
    let geoCodePath = "geo/1.0/direct?"
    let currentWeatherPath = "data/2.5/weather?"
    let forcastPath = "data/2.5/forecast?"
    
    
    
}
