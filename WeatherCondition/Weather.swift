//
//  Weather.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 10/01/2025.
//

import Foundation

struct Main: Decodable {
       let temp: Double
       let tempMin: Double
       let tempMax: Double
     
       enum CodingKeys: String, CodingKey {
            case temp
            case tempMin = "temp_min"
            case tempMax = "temp_max"
       }
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

struct ForcastDetail {
    let day: String
    let theme: ConditionTheme
    let temperature: String
}
