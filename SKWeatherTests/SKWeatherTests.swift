//
//  SKWeatherTests.swift
//  SKWeatherTests
//
//  Created by Sandeep on 03/04/16.
//  Copyright © 2016 com.sk. All rights reserved.
//

import XCTest
@testable import SKWeather

class SKWeatherTests: XCTestCase, SKLogicProtocol {
    var oLogic:  SKLogic!
    var weatherExpectation : XCTestExpectation!
    var uvExpectation : XCTestExpectation!
    
    
    override func setUp() {
        super.setUp()
        // Initialise Log Object
        oLogic = SKLogic()
        //Assign delegate
        oLogic.delegate = self
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        oLogic = nil
    }
    
    func testCheckObject() {
        //Test if oLogic Object is not nil
        XCTAssertNotNil(oLogic, "Logic Object not Nil")
    }
    
    func testAsyncWeatherDownload() {
        //Create Expectation for Temperature Download
        weatherExpectation = self.expectationWithDescription("Weather Download Async")
        
        //Call asynch method to download temp data for San Francisco, United States
        oLogic.getWeatherDataForCity("San Francisco, United States")
        
        //Wait for async data to arrrive
        self.waitForExpectationsWithTimeout(5, handler: {
            (error) in
            if(error != nil)
            {
                XCTFail("Expectation Failed with error: " + (error?.localizedDescription)!)
            }
        })
    }
    
    func testAsyncUVDownload() {
        //Create Expectation for UV Download
        uvExpectation      = self.expectationWithDescription("UV Download Async")
        
        //Call asynch method to download UV data for 40.75,-74.25
        oLogic.getUVDataForCity("40.75,-74.25")
        
        //Wait for async data to arrrive
        self.waitForExpectationsWithTimeout(5, handler: {
            (error) in
            if(error != nil)
            {
                XCTFail("Expectation Failed with error: " + (error?.localizedDescription)!)
            }
        })
        
    }
    
    //This method is called when the Temp Async function returns, Temp Expetation is fulfulled
    func fulfillWeatherExpectation() {
        if (self.weatherExpectation != nil) {
            var onceToken: dispatch_once_t = 0
            dispatch_once(&onceToken) {
                self.weatherExpectation.fulfill()
            }
        }
    }
    
    //This method is called when the UV Async function returns, UV Expetation is fulfulled
    func fulfillUVExpectation() {
        if (self.uvExpectation != nil) {
            var onceToken: dispatch_once_t = 0
            dispatch_once(&onceToken) {
                self.uvExpectation.fulfill()
            }
        }
    }
    //delegate functions
    func weatherDownloadSuccessfull(response: String) {
       fulfillWeatherExpectation()
        XCTAssertTrue(response.isEmpty != true, "Weather Response was successful")
        //I wanted to test for exact value, but I didn't as the temperature keeps on changing
        //XCTAssertTrue(response == "10.1", "\(response) != 10.1. Temp could be wrong, as it changes all the time")
    }
    
    func weatherDownloadFailed(error: String) {
        fulfillWeatherExpectation()
    }
    
    func uvDownloadSuccessfull(response: String) {
        fulfillUVExpectation()
        XCTAssertTrue(response.isEmpty != true, "UV Response was successful")
        //I wanted to test for exact value, but I didn't as the UV keeps on changing
        //XCTAssertTrue(response == "4.6", "\(response) != 4.6. UV could be wrong, as it changes all the time")
    }
    func uvDownloadFailed(error: String) {
        fulfillUVExpectation()
    }
}
