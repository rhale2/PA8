//
//  ViewController.swift
//  PA8
//
//  Created by Rebekah Hale on 11/27/20.
//  Copyright © 2020 Rebekah Hale. All rights reserved.
//

/*
 The user interface has (at a minimum) a table view, a search bar, and an update location button
 When the update location button is pressed, the user’s location is fetched and used for future nearby places searches
 When the search bar’s text field is empty, the table view is empty as well
 When the search bar’s cancel button is tapped, the table view should be cleared out
 When the user types in the search bar and presses the “Search” button on the keyboard (recall: use cmd + K to bring up the keyboard so you can see the Search button), the app fetches nearby places the user that match user’s search text using a Google Places Nearby Search
 While fetching/parsing data, show an indeterminate progress indicator using the MBProgressHUD Cocoapod
 The app requests nearby places that
 Contain the users search text as a keyword
 Are ranked by distance to their current location
 The app displays the returned places in a table view, one cell for each place
 The cell displays (at a minimum) the place’s
 Name
 Vicinity
 Rating
 Tapping on a cell should bring you to PlaceDetailViewController’s screen
 */

import UIKit
import GoogleMaps
import GooglePlaces
import MBProgressHUD
import CoreLocation

class PlaceTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GMSMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    var places = [Place]()
    var placesClient: GMSPlacesClient!
    var search: Bool = false
 
    
    @IBOutlet var searchBarButton: UIBarButtonItem!
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    @IBAction func updateLocationButton(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        showSearchBar()
    }
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchBarButton = navigationItem.rightBarButtonItem
        placesClient = GMSPlacesClient.shared()
        
        if CLLocationManager.locationServicesEnabled() {
                    print("enabled")
                    setupLocationServices()
                }
                else {
                    print("disabled")
                    // the user has turned off location services, airplane mode, HW failure, etc.
                }
              
        // Do any additional setup after loading the view.
    }
    
    func setupLocationServices() {
            // need a CLLocationManager object
            // and we need a delegate object
            locationManager.delegate = self
            
            // we need to get the user's permission (AKA authorization) to access their location
            // two types of authorization for location
            // 1. When in use: the app gets location updates when its running
            // 2. Always: the app always gets location updates. the OS will start the app to deliver an updates
            // we will do 1.
            // we need to add a key-value pair to Info.plist to declare the location services dependency and get permission
            // key: Privacy - Location When in Use Usage Description
            // value: a description of why your app needs this access
            locationManager.requestWhenInUseAuthorization()
            
            // by default the location desired accuracy is "best"
            // you should choose the most course-grained accuracy that your app can tolerate
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
            // two types of location updates
            // 1. requestLocation(): one time update of the location
            // 2. startUpdatingLocation(): continuous updates of the user's location
            // don't forget to call stopUpdatingLocation() when you're done with location
            //locationManager.requestLocation()
            // need delegate callback methods!!
            locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            print(locations)
            // update the labels!
            // we are guaranteed there is at least one location
            // the newest updates are at the end of the array
            let location = locations[locations.count - 1]
            // MAKE FUNC TO GET LAT?LANG
            // we need a geocoder to get name
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placeMarksOptional, errorOptional) in
                if let placeMarks = placeMarksOptional, placeMarks.count > 0 {
                    let placeMark = placeMarks[0]
                    if let name = placeMark.name {
                        //self.nameLabel.text = "Name: \(name)"
                    }
                }
            }
            
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location \(error)")
        // a few notable error codes
        // 0: there is no location (e.g. Simulator location is None)
        // 1: access denied
    }
    
    /**
     Sets how many rows there should be for the Table View.
     
     - Parameter tableView: The Table View.
     - Parameter section: The number of sections in the Table View.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return places.count
        }
        return 0
    }
    
    /**
    Places a Trip in a cell.
    
    - Parameter tableView: The Table View.
    - Parameter indexPath: The cell position.
    */
    func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let place = places[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
            as! PlaceTableViewCell
        cell.update(with: place)
        return cell
    }
    
    /**
     Handles the moving of cells.
     
     - Parameter tableView: The Table View to edit.
     - Parameter sourceIndexPath: The original loctation of the cell.
     - Parameter destinationIndexPth: The new location of the cell.
     */
    func tableView (_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let trip = places.remove(at: sourceIndexPath.row)
        places.insert(trip, at: destinationIndexPath.row)
        tableView.reloadData()
    }
    
    /**
     Handels the deletion of a cell.
     
     - Parameter tableView: The Table View.
     - Parameter editingStyle: The cell editing style.
     - Parameter indexPath: The cell position.
     */
    func tableView (_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            places.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
    
    /**
    handles the preparation for segue
     
     - Parameter segue: The UIStorySegue
     - Parameter sender: The source
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "DetailSegue" {
                if let placeDetailVC = segue.destination as? PlaceDetailViewController {
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let place = places[indexPath.row]
                        //set placeDetailVC
                    }
                }
            }
        }
    }
    
    func showSearchBar() {
        searchBar.alpha = 0
        navigationItem.titleView = searchBar
        UIView.animate(withDuration: 0.5, animations: {
          self.searchBar.alpha = 1
          }, completion: { finished in
            self.searchBar.becomeFirstResponder()
            MBProgressHUD.showAdded(to: self.view, animated: true)
        })
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        GooglePlacesAPI.fetchPlaces(input: searchText)
    }
    
    
    // id: Int, name: String, vicinity: String, rating: Int, photoRefrence: String
    /*func getPlaces () {
        let placeFields: GMSPlaceField = [.placeID, .name, .formattedAddress, .rating, .photos]
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { (placeLikelihoods, error) in
            
            
            guard error == nil else {
                print("Current place error: \(error?.localizedDescription ?? "")")
                return
            }
            
            guard let place = placeLikelihoods?.first?.place, let id = place.placeID, let name = place.name, let address = place.formattedAddress, let photos = place.photos else {
                print("error")
                return
            }
            let rating = place.rating
        }
    }*/
    
    
}
