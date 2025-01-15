//
//  FavouritesViewModel.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 15/01/2025.
//

import Foundation
import Combine
class FavouritesViewModel {
    @Published var favouriteLocations: [FavouriteLocationDetail] = []
    @Published var errorMessage = ""
    let persistence = PersistenceController.shared
    
    func loadFavouriteLocations() {
        favouriteLocations = persistence.getFaouriteLocations()
        
        if favouriteLocations.count == 0 {
            errorMessage = "No Locations Saved!"
        }
    }
}
