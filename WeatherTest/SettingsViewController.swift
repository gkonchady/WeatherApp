//
//  SettingsViewController.swift
//  WeatherTest
//
//  Created by Gaurav Konchady on 1/12/15.
//  Copyright (c) 2015 Gaurav Konchady. All rights reserved.
//

import UIKit
import GooglePlaces

@available(iOS 9.0, *)
class SettingsViewController: UIViewController {

    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    @IBOutlet weak var resultsViewContainer: UIStackView!
    @IBOutlet weak var selectedLocation: UILabel!
    var latitude = ""
    var longitude = ""
    var location = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self

        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

        let screenSize = UIScreen.main.bounds
        let subView = UIView(frame: CGRect(x: 0, y: 65.0, width: screenSize.width, height: 45.0))

        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false

        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true

        resultsViewContainer.isHidden = true
    }

    @IBAction func locationConfirmTapped(_ sender: UIButton) {
        let vc: MainViewController = self.tabBarController?.viewControllers![0] as! MainViewController
        vc.latitude = latitude
        vc.longitude = longitude
        vc.location = location
        self.tabBarController?.selectedIndex = 0
    }

}

// Handle the user's selection.
@available(iOS 9.0, *)
extension SettingsViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        selectedLocation.text = "Selected Location: " + place.name
        resultsViewContainer.isHidden = false
        // Do something with the selected place.
        latitude = String(format: "%f", place.coordinate.latitude)
        longitude = String(format: "%f", place.coordinate.longitude)
        location = place.name
    }

    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }

    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }


}

