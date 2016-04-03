//
//  SKLogic.swift
//  SKWeather
//
//  Created by Sandeep on 03/04/16.
//  Copyright © 2016 com.sk. All rights reserved.
//

import Foundation

//Delefate functions which are called when the data is downloaded from api.openweathermap.org
protocol SKLogicProtocol {
    func weatherDownloadSuccessfull(response: String)
    func weatherDownloadFailed(error: String)
    func uvDownloadSuccessfull(response: String)
    func uvDownloadFailed(error: String)
}

let strAPIKey = "d43f4a078431b9d68bf5d18434dd948c"
let strWeatherBaseUrl = "http://api.openweathermap.org/data/2.5/weather"
let strUVBaseUrl = "http://api.openweathermap.org/v3/uvi/"
let tenMinSecs = 600.0


class SKLogic : NSObject {
    var delegate : SKLogicProtocol!
    
    
    //Function which downloads the weather data from Open Weather Map site
    //@param City: takes in the city for which we need to get the Weather Info
    func getWeatherDataForCity(city: String) {
        
        //As per the API, we should contact the server only once in 10 mins, 
        // so check if 10 mins is over if not then show the last saved value
        let ud = NSUserDefaults.standardUserDefaults()
        if (ud.valueForKey("lastSyncedTimeWeather") != nil) {
            let lastSyncedTimeWeather = ud.valueForKey("lastSyncedTimeWeather") as! NSDate
            let timeElapsed = NSDate().timeIntervalSinceDate(lastSyncedTimeWeather)
            if (timeElapsed < tenMinSecs) {
                let strTemp = ud.valueForKey("lastSavedTemp") as! String
                self.delegate.weatherDownloadSuccessfull(strTemp)
            }
        }
        //City can contain spaces, etc we will have to escape it in the URL
        let escapedCity = city.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        
        //append the escaped city to the URL, units = metric for Celcius
        let strURL =  strWeatherBaseUrl + "?q=" + escapedCity! + "&units=metric&APPID=" + strAPIKey
        
        //Create NSUrl from the url
        let url = NSURL(string: strURL)
        let request = NSMutableURLRequest(URL: url!)
        
        // Create NSURLSession and fire the request
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void  in
            //once we get the response, check if error
            if (error == nil) {
                //if not error then, Serialise the JSON into a Dictionary
                do {
                    let dictData = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                    //extract temperature from the dictionary, which is a number
                    let numTemp = dictData!["main"]!["temp"] as! NSNumber
                    
                    //Round to first place of decimal
                    let strTemp = String(format: "%.1f", numTemp.doubleValue)
                    //since we are in a block which is run in background thread,
                    // call the delegate function in the main thread which will update the UI
                    dispatch_sync(dispatch_get_main_queue()) {
                        //save the last sync time and value in user defaults
                        ud.setValue(NSDate(), forKey: "lastSyncedTimeWeather")
                        ud.setValue(strTemp, forKey: "lastSavedTemp")
                        ud.synchronize()
                        self.delegate.weatherDownloadSuccessfull(strTemp)
                    }
                } catch let error as NSError {
                    //in case of errror
                    dispatch_sync(dispatch_get_main_queue()) {
                        self.delegate.weatherDownloadFailed(error.debugDescription)
                    }
                }
            }
            
        })
        task.resume()
    }
    
    //Function which downloads the weather data from Open Weather Map site
    //@param latlong: takes in the Latitude and Longitude for which we need to get the Weather Info
    func getUVDataForCity(latLong: String) {
        
        //As per the API, we should contact the server only once in 10 mins,
        // so check if 10 mins is over if not then show the last saved value
        let ud = NSUserDefaults.standardUserDefaults()
        if (ud.valueForKey("lastSyncedTimeUV") != nil) {
            let lastSyncedTimeUV = ud.valueForKey("lastSyncedTimeUV") as! NSDate
            let timeElapsed = NSDate().timeIntervalSinceDate(lastSyncedTimeUV)
            if (timeElapsed < tenMinSecs) {
                let strUV = ud.valueForKey("lastSavedUV") as! String
                self.delegate.weatherDownloadSuccessfull(strUV)
            }
        }
        //append the latlong to the URL
        let strURL =  strUVBaseUrl + latLong + "/current.json?appid=" + strAPIKey
        
        //Create NSUrl from the url
        let url = NSURL(string: strURL)
        let request = NSMutableURLRequest(URL: url!)
        
        // Create NSURLSession and fire the request
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void  in
            //once we get the response, check if error
            if (error == nil) {
                //if not error then, Serialise the JSON into a Dictionary
                var strUV = ""
                do {
                    let dictData = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                    //extract UV Index from the dictionary, which is a number
                    if dictData!["data"]  != nil {
                        let numUV = dictData!["data"] as! NSNumber
                        //Round to first place of decimal
                        strUV = String(format: "%.1f", numUV.doubleValue)
                    } else {
                        //if data is not present then it contains message saying not found, so we show N/A
                        strUV = "N/A"
                    }
                    //since we are in a block which is run in background thread,
                    // call the delegate function in the main thread which will update the UI
                    dispatch_sync(dispatch_get_main_queue()) {
                        //save the last sync time and value in user defaults
                        ud.setValue(NSDate(), forKey: "lastSyncedTimeUV")
                        ud.setValue(strUV, forKey: "lastSavedUV")
                        ud.synchronize()
                        self.delegate.uvDownloadSuccessfull(strUV)
                    }
                } catch let error as NSError {
                    //in case of errror
                    dispatch_sync(dispatch_get_main_queue()) {
                        self.delegate.uvDownloadFailed(error.debugDescription)
                    }
                }
            }
            
        })
        task.resume()
    }
}