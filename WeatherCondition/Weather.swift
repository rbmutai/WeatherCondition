//
//  Weather.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 10/01/2025.
//

import Foundation

struct Main: Decodable {
       let temp: Double
}

struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Current: Decodable {
    let weather: [Weather]
    let main: Main
    let name: String?
    let dt: Int
}

struct Forcast: Decodable {
    let list: [Current]
}
