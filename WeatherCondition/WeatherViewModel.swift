//
//  WeatherViewModel.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 13/01/2025.
//

import Foundation
import Combine

class WeatherViewModel {
    @Published var city = ""
    @Published var showActivityIndicator: Bool = false
    @Published var errorMessage: String = ""
    @Published var currentTemperature: String = ""
    @Published var minimumTemperature: String = ""
    @Published var maximumTemperature: String = ""
    @Published var conditions: String = ""
}
