//
//  WeatherViewModel.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 13/01/2025.
//

import Foundation
import Combine

enum ConditionTheme: String {
    case rain
    case cloud
    case clear
    case none
}

class WeatherViewModel {
    @Published var city = ""
    @Published var showActivityIndicator: Bool = false
    @Published var errorMessage: String = ""
    @Published var currentTemperature: String = ""
    @Published var minimumTemperature: String = ""
    @Published var maximumTemperature: String = ""
    @Published var conditions: String = ""
    @Published var province: String = ""
    @Published var street: String = ""
    @Published var lastChecked = ""
    @Published var weatherTheme: ConditionTheme = .none
    @Published var forcastDetail: [ForcastDetail] = []
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    let persistence = PersistenceController.shared
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
                
                self.latitude = latitude
                self.longitude = longitude
                
            } catch {
                showActivityIndicator = false
                processError(error: error)
            }
        
    }
    
    func getLocationDetail(latitude: Double, longitude: Double) async {
        
        do {
            showActivityIndicator = true
            
            let results = try await apiService.fetchLocationDetail(latitude: latitude, longitude: longitude)
            updateLocationDetails(results: results)
            
            showActivityIndicator = false
            
        } catch  {
            showActivityIndicator = false
            processError(error: error)
        }
    }
    
    func processError(error: Error){
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
    
    func updateLocationDetails(results: [ResultDetail]) {
        
        for item in results {
            if item.types.contains("street_address") && street == "" {
               street = item.formattedAddress.components(separatedBy: ",")[0]
            }
            
            if item.types.contains("administrative_area_level_1") && province == "" {
                province = item.formattedAddress
            }
            
            if province != "" && street != "" {
                break
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
        lastChecked = Date().formatted(date: .abbreviated, time: .shortened)
        persistence.saveCurrentWeather(currentTemperature: currentTemperature, maximumTemperature: maximumTemperature, minimumTemperature: minimumTemperature, conditions: conditions.lowercased())
    }
    
    func updateWeatherForcastDetails(forcast:[Current]){
        forcastDetail = []
        var previousDay = ""
        
        for item in forcast {
             let dayOfWeek = getDayOfWeek(timeStamp: Double(item.dt))
             let theme = getWeatherTheme(conditions: item.weather[0].description)
             let temperature = "\(item.main.temp)º"
            
             if previousDay != dayOfWeek {
                 let forcastItem = ForcastDetail(day: dayOfWeek, theme: theme, temperature: temperature)
                 forcastDetail.append(forcastItem)
                 previousDay = dayOfWeek
             }
        }
        
        persistence.saveWeatherForcast(forcast: forcastDetail)
    }
    
    func getSavedWeather() {
        
        if let currentWeather = persistence.getCurrentWeather() {
            if currentTemperature == "" {
                currentTemperature = currentWeather.currentTemperature
            }
            if maximumTemperature == "" {
                maximumTemperature = currentWeather.maximumTemperature
            }
            if minimumTemperature == "" {
                minimumTemperature = currentWeather.minimumTemperature
            }
            if lastChecked == "" {
                lastChecked = currentWeather.createdOn.formatted(date: .abbreviated, time: .shortened)
            }
            if weatherTheme == .none {
                weatherTheme = getWeatherTheme(conditions: currentWeather.conditions)
            }
        }
        
        let forcast = persistence.getWeatherForcast()
        
        if forcastDetail.count == 0 && forcast.count > 0 {
            forcastDetail = forcast
        }
        
    }
    
    func saveLocation() {
        if latitude != 0.0 && longitude != 0.0 {
            persistence.saveFavouriteLocation(city: city, street: street, province: province, latitude: latitude, longitude: longitude)
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
            return .cloud
        } else if conditions.contains("rain") || conditions.contains("drizzle") || conditions.contains("snow") {
            return .rain
        } else if conditions.contains("clear") {
            return .clear
        } else {
            return .rain
        }
    }
    
    func getWeatherIcon(theme: ConditionTheme)-> String {
        switch theme {
        case .cloud:
            return "partlySunny"
        case .rain:
            return "rain"
        case .clear:
            return "clear"
        case .none:
            return "clear"
        }
    }
    
    func getWeatherBackground(theme: ConditionTheme)-> (imageName: String, colorName: String) {
        switch theme {
        case .cloud:
            return ("forestCloudy", "Cloudy")
        case .rain:
            return ("forestRainy","Rainy")
        case .clear:
            return ("forestSunny","Sunny")
        case .none:
            return ("clear","None")
        }
    }
    
    
}
