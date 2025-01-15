//
//  FavouritesViewController.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 14/01/2025.
//

import UIKit
import MapKit
import Combine
class FavouritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var favouritesTableView: UITableView!
    private var subscribers = Set<AnyCancellable>()
    var viewModel: FavouritesViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        favouritesTableView.delegate = self
        favouritesTableView.dataSource = self
        // Do any additional setup after loading the view.
        bind()
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
        
        viewModel.loadFavouriteLocations()
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
           
           completionHandler(true)
            
        }
        
        let viewAction = UIContextualAction(style: .normal, title: "View") {
            (action, sourceView, completionHandler) in
           
           completionHandler(true)
            
        }
        
        viewAction.backgroundColor = UIColor.orange
   
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction,viewAction])
       
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeConfiguration
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true)
    }

}
