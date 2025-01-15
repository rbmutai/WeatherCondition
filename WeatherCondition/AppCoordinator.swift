//
//  AppCoordinator.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 14/01/2025.
//

import Foundation
import UIKit
class AppCoordinator : Coordinator {
    let storyboard = UIStoryboard(name: "Main", bundle: .main)
    
    func start() {
        guard let homeTabBarController = storyboard.instantiateViewController(withIdentifier: "HomeTabBarController") as? HomeTabBarController else { return }
        
        guard let checkWeather = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController else { return }
        let weatherViewModel = WeatherViewModel(apiService: APIService())
        checkWeather.viewModel = weatherViewModel
        
      
        guard let favourites = storyboard.instantiateViewController(withIdentifier: "FavouritesViewController") as? FavouritesViewController else { return }
        let favouritesViewModel = FavouritesViewModel()
        favourites.viewModel = favouritesViewModel

        homeTabBarController.viewControllers = [checkWeather, favourites]
        
        navigationController?.pushViewController(homeTabBarController, animated: true)
    }
}
