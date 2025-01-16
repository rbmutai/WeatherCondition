//
//  ViewController.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 10/01/2025.
//

import UIKit
import Combine
import CoreLocation
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var currentTemperatureMainLabel: UILabel!
    @IBOutlet weak var currentConditionLabel: UILabel!
    @IBOutlet weak var provinceLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var minimumTemperatureLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var maximumTemperatureLabel: UILabel!
    @IBOutlet weak var forcastTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var lastCheckedLabel: UILabel!
    let locationManager = CLLocationManager()
    var coodinates: CLLocation?
    private var subscribers = Set<AnyCancellable>()
    var viewModel : WeatherViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        forcastTableView.delegate = self
        forcastTableView.dataSource = self
        refreshButton.configuration?.baseForegroundColor = UIColor.gray
        
        bind()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 100
        locationManager.delegate = self
        
        checkLocationAuthorization()
    }
    
    func bind() {
        guard let viewModel = viewModel else { return }
        
        viewModel.$showActivityIndicator
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] value in
                if value {
                    activityIndicator.startAnimating()
                } else {
                    activityIndicator.stopAnimating()
                }
            })
            .store(in: &subscribers)
        
        viewModel.$forcastDetail
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] value in
                forcastTableView.reloadData()
                refreshButton.configuration?.baseForegroundColor = UIColor.white
            })
            .store(in: &subscribers)
        
        viewModel.$weatherTheme
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] value in
                let (iconName, colorName) = viewModel.getWeatherBackground(theme: value)
                mainView.backgroundColor = UIColor(named: colorName)
                weatherImage.image = UIImage(named: iconName)
            })
            .store(in: &subscribers)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] value in
                if value != "" {
                    showAlert(message: value)
                }
            })
            .store(in: &subscribers)
        
        viewModel.$conditions
            .receive(on: DispatchQueue.main)
            .assign(to: \.text!, on: currentConditionLabel)
            .store(in: &subscribers)
        
        viewModel.$currentTemperature
            .receive(on: DispatchQueue.main)
            .assign(to: \.text!, on: currentTemperatureMainLabel)
            .store(in: &subscribers)
        
        viewModel.$currentTemperature
            .receive(on: DispatchQueue.main)
            .assign(to: \.text!, on: currentTemperatureLabel)
            .store(in: &subscribers)
        
        viewModel.$minimumTemperature
            .receive(on: DispatchQueue.main)
            .assign(to: \.text!, on: minimumTemperatureLabel)
            .store(in: &subscribers)
        
        viewModel.$maximumTemperature
            .receive(on: DispatchQueue.main)
            .assign(to: \.text!, on: maximumTemperatureLabel)
            .store(in: &subscribers)
        
        viewModel.$city
            .receive(on: DispatchQueue.main)
            .assign(to: \.text!, on: locationLabel)
            .store(in: &subscribers)
        
        viewModel.$street
            .receive(on: DispatchQueue.main)
            .assign(to: \.text!, on: streetLabel)
            .store(in: &subscribers)
        
        viewModel.$province
            .receive(on: DispatchQueue.main)
            .assign(to: \.text!, on: provinceLabel)
            .store(in: &subscribers)
        
        viewModel.$lastChecked
            .receive(on: DispatchQueue.main)
            .assign(to: \.text!, on: lastCheckedLabel)
            .store(in: &subscribers)
        
        viewModel.$refreshEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: refreshButton)
            .store(in: &subscribers)
        
        viewModel.loadSavedData()
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            default:
                return
        }
        
    }
    
// TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.forcastDetail.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! WeatherTableViewCell
        
        if let forcastItem = viewModel?.forcastDetail[indexPath.row] {
            cell.dayLabel.text = forcastItem.day
            cell.temperatureLabel.text = forcastItem.temperature
            let imageName = viewModel?.getWeatherIcon(theme: forcastItem.theme)
            cell.weatherIcon.image = UIImage(named: imageName ?? "rain")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let geoLocation = locations.first {
            coodinates = geoLocation
            
            Task {
                await  viewModel?.getWeather(latitude: geoLocation.coordinate.latitude, longitude: geoLocation.coordinate.longitude)
                
                await  viewModel?.getLocationDetail(latitude: geoLocation.coordinate.latitude, longitude: geoLocation.coordinate.longitude)
            }
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

    
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        if let coodinates = coodinates {
            Task {
                await viewModel?.getWeather(latitude: coodinates.coordinate.latitude, longitude: coodinates.coordinate.longitude)
                
                await  viewModel?.getLocationDetail(latitude: coodinates.coordinate.latitude, longitude: coodinates.coordinate.longitude)
            }
        } else {
            enableLocationAlert(message: "Location Services Disabled. Please enable Location Services in Settings in order to get location based weather information")
        }
    }
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Alert", message: "Save \(viewModel?.city ?? "location") to favourites?", preferredStyle: .alert)
         let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self]
             UIAlertAction in
             self?.viewModel?.saveLocation()
         }
         let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
         alert.addAction(saveAction)
         alert.addAction(cancelAction)
         present(alert, animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true)
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
    

}

