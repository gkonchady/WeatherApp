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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Read url and key from your Settings plist file
        var myDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("Settings", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = myDict {
            weatherApiUrl = dict["Weather API Url"] as String
            weatherApiKey = dict["Weather API Key"] as String
        }
        
        self.lblLocation.text = "Please wait..."
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.distanceFilter = 100.0;
            locationManager.startUpdatingLocation()
        } else {
            println("Location services are not enabled");
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshWeather(sender: UIButton) {
        locationManager.startUpdatingLocation()
    }
    
    // CoreLocation Delegate Methods
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if ((error) != nil) {
            print(error)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as CLLocation
        var coord = locationObj.coordinate
        
        var latitude:String = String(format: "%f", coord.latitude)
        var longitude:String = String(format: "%f", coord.longitude)
        
        locationManager.stopUpdatingLocation()
        
        getTemperatureFromLatLong(latitude, lon: longitude)
    }
    
    func getTemperatureFromLatLong(lat:String, lon:String){
        var weatherUrl = weatherApiUrl + lat + "&lon=" + lon + "&APPID=" + weatherApiKey
        var url = NSURL(string: weatherUrl)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            if let httpRes = response as? NSHTTPURLResponse {
                if httpRes.statusCode == 200 {
                    var dict: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                    var tempdict = dict.valueForKey("main") as NSDictionary
                    var temperature  = self.convertKelvinToFahrenheit(tempdict["temp"] as Double)
                    dispatch_async(dispatch_get_main_queue()){
                        self.lblLocation.text = dict.valueForKey("name") as? String
                        self.lblTemperature.text = temperature
                        self.lblLastUpdated.text = self.getTimestamp()
                    }
                }
            } else {
                println("error \(error)") // print the error!
            }
        }
            
        task.resume()
    }
    
    func convertKelvinToFahrenheit(temp: Double) -> String{
        var fahrenheitTemp = (temp - 273.15)*1.8 + 32
        return String(format: "%dºF", Int(round(fahrenheitTemp)))
    }
    
    func getTimestamp() -> String {
        var timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        timestamp = "Last Updated: " + timestamp
        return timestamp
    }
    
}

