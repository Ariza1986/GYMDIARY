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

struct DayForecast {
    var code:String
    var date:String
    var day:String
    var high:String
    var low:String
    var text:String
    
    init(code: String, date: String, day: String, high: String, low: String, text: String) {
        self.code = code
        self.date = date
        self.day = day
        self.high = high
        self.low = low
        self.text = text
    }
}

class WeatherViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var weahterImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var forecastTable: UITableView!

    
    let locationManager = CLLocationManager()
    let clGeocoder = CLGeocoder()
    
    var forecastList = [DayForecast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("countcountcount" + "\(forecastList.count)")
        return forecastList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "forecastCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = forecastList[indexPath.row].day + "\t" +
                                temptranstion(temp: Double(forecastList[indexPath.row].high)!) + "°\t" +
                                temptranstion(temp: Double(forecastList[indexPath.row].low)!) + "°\t" +
                                forecastList[indexPath.row].text
        return cell
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
        forecastList.removeAll()
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
                self.getWeatherInfo(city: city, countryCode: countryCode)
            }
        })
    }
    
    //⬇︎⬇︎--------requestWeatherAPI---------⬇︎⬇︎
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
                            
                            OperationQueue.main.addOperation {
                                self.sunriseLabel.text = sunrise
                                self.sunsetLabel.text = sunset
                            }
                        }
                    
                        if  let items = channel["item"] as? [String: Any] {
                            
                            if  let condition = items["condition"] as? [String: Any],
                                let temp = condition["temp"] as? String,
                                let text = condition["text"] as? String {
                                
                                    OperationQueue.main.addOperation {
                                        self.tempLabel.text = self.temptranstion(temp: Double(temp)!) + "°C"
                                        self.conditionLabel.text = text
                                    }
                                }
                            
                            if  let forecasts = items["forecast"] as? NSArray {
                                for forecast in forecasts {
                                    if  let detail = forecast as? NSDictionary,
                                        let code = detail["code"] as? String,
                                        let date = detail["date"] as? String,
                                        let day = detail["day"] as? String,
                                        let high = detail["high"] as? String,
                                        let low = detail["low"] as? String,
                                        let text = detail["text"] as? String {
                                        
                                        OperationQueue.main.addOperation {
                                            let dayforecast = DayForecast(code: code, date: date, day: day, high: high, low: low, text: text)
                                            self.forecastList.append(dayforecast)
                                        }
                                    }
                                }
                                OperationQueue.main.addOperation {
                                    self.forecastTable.reloadData()
                                }
                            }
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
    
    func temptranstion(temp: Double) -> String {
        
        return String(Int((temp - 32) * 5 / 9))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
