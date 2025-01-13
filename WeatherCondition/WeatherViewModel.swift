//
//  WeatherViewModel.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 13/01/2025.
//

import Foundation
import Combine

enum ConditionTheme: String {
    case rainy
    case cloudy
    case clear
}

class WeatherViewModel {
    @Published var city = ""
    @Published var showActivityIndicator: Bool = false
    @Published var errorMessage: String = ""
    @Published var currentTemperature: String = ""
    @Published var minimumTemperature: String = ""
    @Published var maximumTemperature: String = ""
    @Published var conditions: String = ""
    @Published var weatherTheme: ConditionTheme = .clear
    @Published var forcastDetail: [ForcastDetail] = []
    
    let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    func getWeather (latitude: Double, longitude: Double) async {
        
            do {
               
                showActivityIndicator = true
                
                async let currentWeather = apiService.fetchCurrentWeather(latitude: latitude, longitude: longitude)
                
                async let weatherForcast = apiService.fetchWeatherForcast(latitude: latitude, longitude: longitude)
               
                let (current, forcast) = try await (currentWeather, weatherForcast)
                
                updateCurrentWeatherDetails(current: current)
                
                updateWeatherForcastDetails(forcast: forcast)
                
                showActivityIndicator = false
                
            } catch {
                showActivityIndicator = false
                
                switch error {
                    case ResultError.network:
                        errorMessage = "Network error"
                    case ResultError.parsing:
                        errorMessage = "Parsing error"
                    case ResultError.data:
                        errorMessage = "Data error"
                    default:
                        errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        
    }
    
    func updateCurrentWeatherDetails(current: Current){
        
        currentTemperature = "\(current.main.temp)º"
        minimumTemperature = "\(current.main.tempMin)º"
        maximumTemperature = "\(current.main.tempMax)º"
        conditions = current.weather[0].description.uppercased()
        weatherTheme = getWeatherTheme(conditions: conditions.lowercased())
        city = current.name ?? ""
    }
    
    func updateWeatherForcastDetails(forcast:[Current]){
        forcastDetail = []
        var previousDay = ""
        let today = getDayOfWeek(timeStamp: Date().timeIntervalSince1970)
        
        for item in forcast {
             let dayOfWeek = getDayOfWeek(timeStamp: Double(item.dt))
             let theme = getWeatherTheme(conditions: item.weather[0].description)
             let temperature = "\(item.main.temp)º"
            
             if previousDay != dayOfWeek && dayOfWeek != today {
                 let forcastItem = ForcastDetail(day: dayOfWeek, theme: theme, temperature: temperature)
                 forcastDetail.append(forcastItem)
                 previousDay = dayOfWeek
             }
        }
    }
    
    func getDayOfWeek(timeStamp: Double)-> (String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        let currentDate = Date(timeIntervalSince1970: timeStamp)
        
        return dateFormatter.string(from: currentDate)
        
    }
    
    func getWeatherTheme(conditions: String) -> ConditionTheme {
        if conditions.contains("cloud") {
            return .cloudy
        } else if conditions.contains("rain") || conditions.contains("drizzle") || conditions.contains("snow") {
            return .rainy
        } else if conditions.contains("clear") {
            return .clear
        } else{
            return .rainy
        }
    }
    
    func getWeatherIcon(theme: ConditionTheme)-> String {
        switch theme {
        case .cloudy:
            return "partlySunny"
        case .rainy:
            return "rain"
        case .clear:
            return "clear"
        }
    }
    
    func getWeatherBackground(theme: ConditionTheme)-> (imageName: String, colorName: String) {
        switch theme {
        case .cloudy:
            return ("forestCloudy", "Cloudy")
        case .rainy:
            return ("forestRainy","Rainy")
        case .clear:
            return ("forestSunny","Sunny")
        }
    }
    
    
}
