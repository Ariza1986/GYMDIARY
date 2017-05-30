//
//  WeatherViewController.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/5/27.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class WeatherViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let clGeocoder = CLGeocoder()
    
    var sunset = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
    }
    
    //⬇︎⬇︎--------requestWhenInUseAuthorization---------⬇︎⬇︎
    override func viewDidAppear(_ animated: Bool) {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        else if CLLocationManager.authorizationStatus() == .denied {
            print("Location services were previously denied. Please enable location services for this app in Settings.")
        }
        else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        manager.stopUpdatingLocation()
        
        clGeocoder.reverseGeocodeLocation(locationManager.location!, completionHandler: { (placemarks, error) -> Void in
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]

            //print(placeMark.addressDictionary!, terminator: "")
            if let city = placeMark.addressDictionary!["City"] as? String, let countryCode = placeMark.addressDictionary!["CountryCode"] as? String{
                self.cityLabel.text = city
                self.countryCodeLabel.text = countryCode
                self.getWeatherInfo(city: city, countryCode: countryCode)
            }
        })
    }
    
    func getWeatherInfo (city: String, countryCode: String) {

        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        //unicode
        let correctCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let correctCountryCode = countryCode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let url = URL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22\(correctCity)%2C%20\(correctCountryCode)%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) -> Void in
            if let error = error {
                print(error)
            }
            self.sunriseLabel.text = "123"
            do {
                if  let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let query = json["query"] as? [String: Any],
                    let results = query["results"] as? [String: Any],
                    let channel = results["channel"] as? [String: Any] {
                        if  let astronomy = channel["astronomy"] as? [String: Any],
                            let sunrise = astronomy["sunrise"] as? String,
                            let sunset = astronomy["sunset"] as? String {
                            print(sunrise)
                            self.sunriseLabel.text = sunrise
                            self.sunset = sunset
                        }
                    
                        if let items = channel["item"] as? [String: Any] {
                            print(items)
                        }
                    }
            }
            catch {
                    print("Error deserializing JSON: \(error)")
            }
            
            if let response = response {
                let httpResponse = response as! HTTPURLResponse
                print("response code = \(httpResponse.statusCode)")
            }
        })
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
