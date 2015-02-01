//
//  SettingsViewController.swift
//  WeatherTest
//
//  Created by Gaurav Konchady on 1/12/15.
//  Copyright (c) 2015 Gaurav Konchady. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var txtLocation: UITextField!
    
    var placesApiUrl = ""
    var placesApiKey = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Read url and key from your Settings plist file
        var myDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("Settings", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = myDict {
            placesApiUrl = dict["Places API AutoComplete Url"] as String
            placesApiKey = dict["Places API Key"] as String
        }
        
        println(placesApiUrl)
        println(placesApiKey)
        
        self.txtLocation.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        self.txtLocation.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField:UITextField!) -> Bool {
        txtLocation.resignFirstResponder()
        return true
    }
}

