//
//  Coordinator.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 14/01/2025.
//

import Foundation
import UIKit

class Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func add(child: Coordinator){
        childCoordinators.append(child)
    }
}

