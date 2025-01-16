//
//  FavouritesViewController.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 14/01/2025.
//

import UIKit
import MapKit
import Combine
import CoreLocation
class FavouritesViewController: UIViewController, UITabBarControllerDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var favouritesTableView: UITableView!
    let locationManager = CLLocationManager()
    private var subscribers = Set<AnyCancellable>()
    var viewModel: FavouritesViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        favouritesTableView.delegate = self
        favouritesTableView.dataSource = self
        self.tabBarController?.delegate = self
        // Do any additional setup after loading the view.
        bind()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 100
        locationManager.delegate = self
        
        checkLocationAuthorization()
    }
    
    func bind() {
        guard let viewModel = viewModel else { return }
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] value in
                if value != "" {
                    showAlert(message: value)
                }
            })
            .store(in: &subscribers)
        
        viewModel.$favouriteLocations
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] value in
                favouritesTableView.reloadData()
            })
            .store(in: &subscribers)
        
        viewModel.$mapAnnotations
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] value in
                mapView.removeAnnotations(mapView.annotations)
                mapView.addAnnotations(value)
            })
            .store(in: &subscribers)
        
        viewModel.loadFavouriteLocations()
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                enableLocationAlert(message: "Location Services Disabled. Please enable Location Services in Settings in order to get location based weather information")
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
            default:
                return
        }
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 1 {
            viewModel?.loadFavouriteLocations()
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.favouriteLocations.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FavouritesTableViewCell
        
        if let item = viewModel?.favouriteLocations[indexPath.row] {
            cell.cityLabel.text = item.city
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (action, sourceView, completionHandler) in
            
            if let locationItem = self.viewModel?.favouriteLocations[indexPath.row] {
                self.viewModel?.deleteFavouriteLocation(city: locationItem.city)
                self.viewModel?.loadFavouriteLocations()
            }
           
           completionHandler(true)
            
        }
        
        let viewAction = UIContextualAction(style: .normal, title: "View") {
            (action, sourceView, completionHandler)  in
            
            if let locationItem = self.viewModel?.favouriteLocations[indexPath.row] {
                self.mapView.setCenter(CLLocationCoordinate2D(latitude: locationItem.latitude, longitude: locationItem.longitude), animated: true)
            }
           
           completionHandler(true)
            
        }
        
        viewAction.backgroundColor = UIColor.orange
   
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction,viewAction])
       
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeConfiguration
    }
    
    //Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        if let geoLocation = locations.first {
            viewModel?.updateCurrentLocation(latitude: geoLocation.coordinate.latitude, longitude: geoLocation.coordinate.longitude)
            mapView.setCenter(CLLocationCoordinate2D(latitude: geoLocation.coordinate.latitude, longitude: geoLocation.coordinate.longitude), animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(message: "Failed to get location: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
       
        switch locationManager.authorizationStatus {
            case .restricted, .denied:
                enableLocationAlert(message: "Location Services Disabled. Please enable Location Services in Settings in order to get location based weather information")
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
            default:
                return
        }
    }
    
    func enableLocationAlert(message: String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
       
        let approveAction = UIAlertAction(title: "Settings", style: .default) {
            UIAlertAction in
            
                let settingsURL = URL(string: UIApplication.openSettingsURLString)!
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Ignore", style: .default, handler: nil)
        alert.addAction(approveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true)
    }

}
