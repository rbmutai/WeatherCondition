//
//  MapAnnotation.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 16/01/2025.
//

import Foundation
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var city: String
    init(coordinate: CLLocationCoordinate2D, city: String) {
        self.coordinate = coordinate
        self.city = city
    }
}
