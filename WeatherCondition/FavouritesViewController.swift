//
//  FavouritesViewController.swift
//  WeatherCondition
//
//  Created by Robert Mutai on 14/01/2025.
//

import UIKit
import MapKit
class FavouritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var favouritesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        favouritesTableView.delegate = self
        favouritesTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FavouritesTableViewCell
        
        return cell
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
        
   
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction,viewAction])
       
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeConfiguration
    }

}
