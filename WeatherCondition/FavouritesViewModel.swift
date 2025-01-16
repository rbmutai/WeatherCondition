//
//  FavouritesViewModel.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 15/01/2025.
//

import Foundation
import Combine
import MapKit
class FavouritesViewModel {
    
    @Published var favouriteLocations: [FavouriteLocationDetail] = []
    @Published var errorMessage = ""
    @Published var mapAnnotations : [MapAnnotation] = []
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    let persistence = PersistenceController.shared
    
    func loadFavouriteLocations() {
        favouriteLocations = persistence.getFaouriteLocations()
        mapAnnotations = []
        
        if favouriteLocations.count == 0 {
            errorMessage = "No Locations Saved!"
            
        } else {
            var annotations: [MapAnnotation] = []
            for item in favouriteLocations {
                let annotation = MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude), city: item.city)
                annotations.append(annotation)
            }
            mapAnnotations =  annotations
        }
        
        if latitude != 0.0 && longitude != 0.0 {
            let annotation = MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), city: "My Location")
            mapAnnotations.append(annotation)
        }
    }
    
    func deleteFavouriteLocation(city: String) {
        persistence.deleteFavouriteLocation(city: city)
    }
    
    func updateCurrentLocation(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        loadFavouriteLocations()
    }
    
}
