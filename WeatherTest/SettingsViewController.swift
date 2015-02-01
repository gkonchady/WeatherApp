//
//  SettingsViewController.swift
//  WeatherTest
//
//  Created by Gaurav Konchady on 1/12/15.
//  Copyright (c) 2015 Gaurav Konchady. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet var txtLocation: UITextField!
    @IBOutlet var tblAutoComplete: UITableView!
    
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
        
        self.txtLocation.delegate = self
        self.tblAutoComplete.delegate = self
        self.tblAutoComplete.dataSource = self
        self.tblAutoComplete.scrollEnabled = true
        self.tblAutoComplete.hidden = true
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
        self.tblAutoComplete.hidden = true
    }
    
    func textFieldShouldReturn(textField:UITextField!) -> Bool {
        txtLocation.resignFirstResponder()
        self.tblAutoComplete.hidden = true
        return true
    }
    
    func textField(textField: UITextField!, shouldChangeCharactersInRange range: NSRange, replacementString string: String!) -> Bool {
        var txtAfterUpdate: NSString = self.txtLocation.text as NSString
        self.tblAutoComplete.hidden = false
        txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
        return true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }


}

