//
//  FavouritesViewModel.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 15/01/2025.
//

import Foundation
import Combine

protocol FavouritesViewModelProtocol: AnyObject {
    func favouriteSaved()
}

class FavouritesViewModel: FavouritesViewModelProtocol {
    
    @Published var favouriteLocations: [FavouriteLocationDetail] = []
    @Published var errorMessage = ""
    let persistence = PersistenceController.shared
    
    func loadFavouriteLocations() {
        favouriteLocations = persistence.getFaouriteLocations()
        
        if favouriteLocations.count == 0 {
            errorMessage = "No Locations Saved!"
        }
    }
    
    func favouriteSaved() {
        favouriteLocations = persistence.getFaouriteLocations()
    }
}
