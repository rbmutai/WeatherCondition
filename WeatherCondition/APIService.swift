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
    
    
}
