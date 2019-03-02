//
//  MainViewController.swift
//  WeatherTest
//
//  Created by Gaurav Konchady on 1/12/15.
//  Copyright (c) 2015 Gaurav Konchady. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()

    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var lblTemperature: UILabel!
    @IBOutlet var lblLastUpdated: UILabel!
    
    var weatherApiUrl = ""
    var weatherApiKey = ""
    var latitude = ""
    var longitude = ""
    var location = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Read url and key from your Settings plist file
        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "Settings", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = myDict {
            weatherApiUrl = dict["Weather API Url"] as! String
            weatherApiKey = dict["Weather API Key"] as! String
        }
        
        self.lblLocation.text = "Please wait..."

        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.distanceFilter = 100.0;
            locationManager.startUpdatingLocation()
        } else {
            print("Location services are not enabled");
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeground(_:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        if !(latitude.isEmpty && longitude.isEmpty && location.isEmpty) {
            lblLocation.text = location
            getTemperatureFromLatLong(lat: latitude, lon: longitude)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc func applicationWillEnterForeground(_ notification: NSNotification) {
        locationManager.startUpdatingLocation()
    }

    @IBAction func refreshWeather(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
    }
    
    // CoreLocation Delegate Methods

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        debugPrint(error.localizedDescription)
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        
        let latitude:String = String(format: "%f", coord.latitude)
        let longitude:String = String(format: "%f", coord.longitude)
        
        CLGeocoder().reverseGeocodeLocation(locationObj, completionHandler: { (placemarks, error) -> Void in
            if((error) != nil){
                debugPrint("error:  \(String(describing: error))")
            } else {
                var pm: CLPlacemark!
                pm = placemarks?[0]
                var address = ""
                if let city = pm?.addressDictionary?["City"] as? String {
                    address += city + ", "
                }
                if let state = pm?.addressDictionary?["State"] as? String {
                    address += state
                }
                self.lblLocation.text = address
            }
        })

        locationManager.stopUpdatingLocation()
        
        getTemperatureFromLatLong(lat: latitude, lon: longitude)
    }
    
    func getTemperatureFromLatLong(lat:String, lon:String){
        let weatherUrl = weatherApiUrl + lat + "&lon=" + lon + "&APPID=" + weatherApiKey
        let url = NSURL(string: weatherUrl)
        
        let task = URLSession.shared.dataTask(with: url! as URL) {(data, response, error) in
            if let httpRes = response as? HTTPURLResponse {
                if httpRes.statusCode == 200 {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                    if let dict = json as? [String: Any] {
                        let tempdict = dict["main"] as? NSDictionary
                        let temperatureVal = tempdict?["temp"] as? Double
                        let temperature  = self.formatTemperature(temp: temperatureVal!)
                        DispatchQueue.main.async(){
                            self.lblTemperature.text = temperature
                            self.lblLastUpdated.text = self.getTimestamp()
                        }
                    }
                }
            } else {
                debugPrint("error \(String(describing: error))") // print the error!
            }
        }
            
        task.resume()
    }
    
    func formatTemperature(temp: Double) -> String {
        return String(format: "%dºF", Int(round(temp)))
    }
    
    func getTimestamp() -> String {
        var timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .short)
        timestamp = "Last Updated: " + timestamp
        return timestamp
    }
    
}

