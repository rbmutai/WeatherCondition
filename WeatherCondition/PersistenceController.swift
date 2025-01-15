//
//  PersistenceController.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 15/01/2025.
//

import Foundation
import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    let viewContext: NSManagedObjectContext

    init(inMemory: Bool = false){
        container = NSPersistentContainer(name: "WeatherCondition")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
            }
        })
        
        viewContext = container.viewContext
    }
    
    func saveCurrentWeather(currentTemperature: String, maximumTemperature: String, minimumTemperature: String, conditions: String){
        
        deleteWeather(entityName: "WeatherCurrent")
        
        if let entity = NSEntityDescription.entity(forEntityName: "WeatherCurrent", in: viewContext){
            let object = NSManagedObject(entity: entity, insertInto: viewContext)
            object.setValue(currentTemperature, forKey: "currentTemperature")
            object.setValue(maximumTemperature, forKey: "maximumTemperature")
            object.setValue(minimumTemperature, forKey: "minimumTemperature")
            object.setValue(conditions, forKey: "conditions")
            object.setValue(Date(), forKey: "createdOn")
        }
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func getCurrentWeather() -> (currentTemperature: String, minimumTemperature: String, maximumTemperature: String, createdOn: Date)? {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WeatherCurrent")
        
        do {
            let object = try viewContext.fetch(fetchRequest)
              if let item = object.first {
                let currentTemperature = item.value(forKey: "currentTemperature") as? String ?? ""
                let minimumTemperature = item.value(forKey: "minimumTemperature") as? String ?? ""
                let maximumTemperature = item.value(forKey: "maximumTemperature") as? String ?? ""
                let createdOn = item.value(forKey: "createdOn") as? Date ?? .distantFuture
               
                return (currentTemperature, minimumTemperature, maximumTemperature, createdOn)
            }
            
            return .none
            
        } catch let error as NSError {
            print("Error \(error.localizedDescription)")
        }
        
        return .none
    }
    
    func saveWeatherForcast(forcast: [ForcastDetail]){
        
        deleteWeather(entityName: "WeatherForcast")
        
        for item in forcast {
            
            if let entity = NSEntityDescription.entity(forEntityName: "WeatherForcast", in: viewContext){
                let object = NSManagedObject(entity: entity, insertInto: viewContext)
                object.setValue(item.day, forKey: "weekday")
                object.setValue(item.temperature, forKey: "temperature")
                object.setValue(item.theme.rawValue, forKey: "conditions")
            }
            
            if viewContext.hasChanges {
                do {
                    try viewContext.save()
                } catch let error as NSError {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        
    }
    
    func getWeatherForcast() -> [ForcastDetail] {
        var forcast: [ForcastDetail] = []
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WeatherForcast")
        
        do {
            let object = try viewContext.fetch(fetchRequest)
             
            for item in object {
                let conditions = item.value(forKey: "conditions") as? String ?? ""
                let temperature = item.value(forKey: "temperature") as? String ?? ""
                let weekday = item.value(forKey: "weekday")  as? String ?? ""
                let theme = getWeatherTheme(conditions: conditions)
                
                let forcastItem = ForcastDetail(day: weekday, theme: theme, temperature: temperature)
                forcast.append(forcastItem)
            }
            
            return forcast
            
        } catch let error as NSError {
            print("Error \(error.localizedDescription)")
        }
        
        return forcast
    }
    
    func deleteWeather(entityName: String) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        do {
            let object = try viewContext.fetch(fetchRequest)
            for item in object {
                viewContext.delete(item)
            }
            try viewContext.save()
            
        } catch let error as NSError {
            print("Error \(error.localizedDescription)")
        }
    }
    
    func saveFavouriteLocation(city: String, street: String, province: String, latitude: Double, longitude: Double){
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavouriteLocation")
        fetchRequest.predicate = NSPredicate(format: "city == %@", city)
        
        do {
            let locationObject = try viewContext.fetch(fetchRequest)
            
            if locationObject.count > 0 {
                return
            }
            
            if let entity = NSEntityDescription.entity(forEntityName: "FavouriteLocation", in: viewContext){
                let object = NSManagedObject(entity: entity, insertInto: viewContext)
                object.setValue(city, forKey: "city")
                object.setValue(street, forKey: "street")
                object.setValue(province, forKey: "province")
                object.setValue(latitude, forKey: "latitude")
                object.setValue(longitude, forKey: "longitude")
            }
            
            if viewContext.hasChanges {
                try viewContext.save()
            }
            
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
    }
    
    func getFaouriteLocations() -> [FavouriteLocationDetail] {
        var favourites: [FavouriteLocationDetail] = []
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavouriteLocation")
        
        do {
            let object = try viewContext.fetch(fetchRequest)
             
            for item in object {
                let city = item.value(forKey: "city") as? String ?? ""
                let street = item.value(forKey: "street") as? String ?? ""
                let province = item.value(forKey: "province")  as? String ?? ""
                let latitude = item.value(forKey: "latitude")  as? Double ?? 0.0
                let longitude = item.value(forKey: "longitude")  as? Double ?? 0.0
              
                let favouritesItem = FavouriteLocationDetail(street: street, city: city, province: province, latitude: latitude, longitude: longitude)
                favourites.append(favouritesItem)
            }
            
            return favourites
            
        } catch let error as NSError {
            print("Error \(error.localizedDescription)")
        }
        
        return favourites
    }
    
    func deleteFavouriteLocation(city: String){
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavouriteLocation")
        fetchRequest.predicate = NSPredicate(format: "city == %@", city)
        
        do {
            let locationObject = try viewContext.fetch(fetchRequest)
            
            for item in locationObject {
                viewContext.delete(item)
            }
            
            try viewContext.save()
            
        } catch let error as NSError {
            print("Error \(error.localizedDescription)")
        }
    }
    
    func getWeatherTheme(conditions: String) -> ConditionTheme {
        if conditions.contains("cloud") {
            return .cloud
        } else if conditions.contains("rain") {
            return .rain
        } else if conditions.contains("clear") {
            return .clear
        } else {
            return .none
        }
    }
}
