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
    let autocompleteTableView = UITableView(frame: CGRectMake(0, 120, 320, 120), style: UITableViewStyle.Plain)
    
    var placesApiUrl = ""
    var placesApiKey = ""
    var pastPlaces = [""]
    var autocompletePlaces = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        autocompleteTableView.scrollEnabled = true
        autocompleteTableView.hidden = true
        self.view.addSubview(autocompleteTableView)
        
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
        autocompleteTableView.hidden = true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        txtLocation.text = ""
    }
    
    func textFieldShouldReturn(textField:UITextField!) -> Bool {
        txtLocation.resignFirstResponder()
        autocompleteTableView.hidden = true
        return true
    }
    
    func textField(textField: UITextField!, shouldChangeCharactersInRange range: NSRange, replacementString string: String!) -> Bool {
        var txtAfterUpdate: NSString = self.txtLocation.text as NSString
        autocompleteTableView.hidden = false
        txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
        searchAutoCompleteWithResults(txtAfterUpdate)
        return true
    }
    
    func searchAutoCompleteWithResults(txtToUpdate:String){
        //if string length is greater than one
        if countElements(txtToUpdate) > 1 {
            var placesUrl = placesApiUrl + txtToUpdate + "&types=geocode&key=" + placesApiKey
            var url = NSURL(string: placesUrl)
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
                if let httpRes = response as? NSHTTPURLResponse {
                    if httpRes.statusCode == 200 {
                        var dict: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                        if let predictions = dict["predictions"] as? NSArray {
                            self.autocompletePlaces.removeAll(keepCapacity: false)
                            for place in predictions{
                                var curString = place["description"] as NSString
                                var myString:NSString! = curString
                                myString = myString.lowercaseString
                                var substringRange :NSRange! = myString.rangeOfString(txtToUpdate)
                                if (substringRange.location == 0)
                                {
                                    self.autocompletePlaces.append(curString)
                                }
                            }
                        }
                     }
                } else {
                    println("error \(error)") // print the error!
                }
            }
            
            task.resume()
            autocompleteTableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompletePlaces.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let autoCompleteRowIdentifier = "AutoCompleteRowIdentifier"
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: autoCompleteRowIdentifier)
        cell.textLabel!.text = autocompletePlaces[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        txtLocation.text = selectedCell.textLabel!.text
        autocompleteTableView.hidden = true
        self.view.endEditing(true)
    }
}

