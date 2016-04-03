//
//  MainViewController.swift
//  SKWeather
//
//  Created by Sandeep on 03/04/16.
//  Copyright © 2016 com.sk. All rights reserved.
//

import UIKit
import CoreLocation


class MainViewController: UIViewController, CLLocationManagerDelegate, SKLogicProtocol {

    @IBOutlet weak var lblWeatherHeading: UILabel!
    @IBOutlet weak var lblWeatherValue: UILabel!
    @IBOutlet weak var lblUVHeading: UILabel!
    @IBOutlet weak var lblUVValue: UILabel!
    @IBOutlet weak var txtLocation: UITextField!
    var locationManager: CLLocationManager!

    var oLogic:  SKLogic!
    var latLong = ""
    var authorizationStatus = CLLocationManager.authorizationStatus()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create Location Manager instance
        locationManager = CLLocationManager()
        
        //Create Instance of Model Class
        oLogic = SKLogic()
        
        //assign delegate
        locationManager.delegate = self
        oLogic.delegate = self
        
        //Get permission to get location. Mandatory by Apple
        // Otherwise you will not get the location
        if (authorizationStatus == .Denied || authorizationStatus == .NotDetermined ) {
            locationManager.requestWhenInUseAuthorization()
        }
    
        //Since we want to get the weather in a city, we don't need best accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //Get the location, only if permission provided
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func findWeather() {
        if(txtLocation.text?.isEmpty == true) {
            let alert = UIAlertController(title: "No Location", message: "No Location Selected. Please change the value under Security Preferences", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
                //Do some stuff
            }
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        lblWeatherHeading.hidden = true
        lblWeatherValue.hidden = true
        lblUVValue.hidden = true
        lblUVHeading.hidden = true
        SVProgressHUD.showWithStatus("Getting Weather for Location: " + txtLocation.text!, maskType: .Black)
        oLogic.getWeatherDataForCity(txtLocation.text!)
        oLogic.getUVDataForCity(latLong)
    }
    
    
    //Location Manager Delegate function
    // This is called when the Location Manager is successful in determining the location of the device
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //We have got the location, stop the process which continues to get the location
        locationManager.stopUpdatingLocation()
        
        //Location is in locations array
        let userLocation:CLLocation = locations[0]
        
        let latitude = String(format: "%.1f", Double(userLocation.coordinate.latitude))
        let longitude = String(format: "%.1f", Double(userLocation.coordinate.longitude))
        latLong = ("\(latitude),\(longitude)")
        
        //we need to reverse geo code to get the location of the place we are in
        // this is required to show in the app and also to get the value from the api
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(userLocation, completionHandler: {
            (placemarks, error) in
            if error == nil && placemarks!.count > 0 {
                //Placemark object reverse codes the location and 
                // gives us info like country, city, zipcode etc.
                let placemark = placemarks![0] as CLPlacemark
                let country = placemark.country
                let city = placemark.locality
                //set the city and country in the textbox
                self.txtLocation.text = city! + "," + country!
            }
        })
    }
    
    //Delegate functions
    
    //Delegate function called when Temperature info is successfully downloaded
    func weatherDownloadSuccessfull(response: String) {
        //Unhide the labels for Temperature
        lblWeatherHeading.hidden = false
        lblWeatherValue.hidden = false

        //See if UV labels are also visible then remove the HUD
        lblWeatherValue.text! = response
        if (lblUVValue.hidden == false) {
            SVProgressHUD.dismiss()
        }
    }
    
    
    //Delegate function called when Temperature info Download Fails
    func weatherDownloadFailed(error: String) {
        //Unhide the labels for Temperature
        lblWeatherHeading.hidden = false
        lblWeatherValue.hidden = false
        
        //See if UV labels are also visible then remove the HUD
        lblWeatherValue.text! = "Err"
        let alert = UIAlertController(title: "Error", message: "Error Occurred: " + error, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
            //Do some stuff
        }
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
        if (lblUVValue.hidden == false) {
            SVProgressHUD.dismiss()
        }

    }
    
    //Delegate function called when UV Index info is successfully downloaded
    func uvDownloadSuccessfull(response: String) {
        //Unhide the labels for UV
        lblUVValue.hidden = false
        lblUVHeading.hidden = false
        
        lblUVValue.text! = response
        //See if Temp Labels are also visible then remove the HUD
        if (lblWeatherValue.hidden == false) {
            SVProgressHUD.dismiss()
        }
    }
    
    //Delegate function called when UV Index infoDownload Fails
    func uvDownloadFailed(error: String) {
        //Unhide the labels for UV
        lblUVValue.hidden = false
        lblUVHeading.hidden = false
        
        //Show error message
        let alert = UIAlertController(title: "Error", message: "Error Occurred: " + error, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in
            //Do some stuff
        }
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
        lblUVValue.text! = "ERR"
        //See if Temp Labels are also visible then remove the HUD
        if (lblWeatherValue.hidden == false) {
            SVProgressHUD.dismiss()
        }
    }
}

