//
//  MockAPIService.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 13/01/2025.
//

import Foundation

class MockAPIService: APIServiceProtocol {
    func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> Current {
        guard let bundleUrl = Bundle.main.url(forResource: "CurrentWeather", withExtension: "json") else {
            throw ResultError.data }
        
        do {
            let data = try Data(contentsOf: bundleUrl)
            
            let decoder = JSONDecoder()
            
            let weather = try decoder.decode(Current.self, from: data)
            
            return weather
            
        } catch {
            throw ResultError.parsing
        }
    }
    
    func fetchWeatherForcast(latitude: Double, longitude: Double) async throws -> [Current] {
        guard let bundleUrl = Bundle.main.url(forResource: "ForcastWeather", withExtension: "json") else {
            throw ResultError.data }
        
        do {
            let data = try Data(contentsOf: bundleUrl)
            
            let decoder = JSONDecoder()
            
            let weather = try decoder.decode(Forcast.self, from: data)
            let forcast = weather.list
            
            return forcast
            
        } catch {
            throw ResultError.parsing
        }
    }
    
    func fetchLocationDetail(latitude: Double, longitude: Double) async throws -> [ResultDetail] {
        guard let bundleUrl = Bundle.main.url(forResource: "LocationDetailData", withExtension: "json") else {
            throw ResultError.data }
        
        do {
            let data = try Data(contentsOf: bundleUrl)
            
            let decoder = JSONDecoder()
            let locationDetail = try decoder.decode(LocationDetail.self, from: data)
            
            return locationDetail.results
            
        } catch {
            throw ResultError.parsing
        }
    }
    
}
