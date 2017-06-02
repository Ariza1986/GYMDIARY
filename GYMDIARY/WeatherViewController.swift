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

class WeatherViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var skyImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var forecastTable: UITableView!

    var refreshControl: UIRefreshControl!
    
    let locationManager = CLLocationManager()
    let clGeocoder = CLGeocoder()
    
    var forecastList = [DayForecast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        forecastTable.allowsSelection = false
        
        //⬇︎⬇︎--------Refresh Ctrl-------⬇︎⬇︎
        refreshControl = UIRefreshControl()
        forecastTable.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Weather Data ...")
    }
    
    //⬇︎⬇︎--------Refresh Ctrl-------⬇︎⬇︎
    func refreshData(sender: UIRefreshControl) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
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
        clGeocoder.reverseGeocodeLocation(manager.location!, completionHandler: { (placemarks, error) -> Void in
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]

            //print(placeMark.addressDictionary!, terminator: "")
            if let city = placeMark.addressDictionary!["City"] as? String, let countryCode = placeMark.addressDictionary!["CountryCode"] as? String{
                self.getWeatherInfo(city: city, countryCode: countryCode)
                self.locationManager.stopUpdatingLocation()
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
            
            DispatchQueue.main.async {
                // Update UI
            
                if let error = error {
                    print(error)
                }
                
                do {
                    if  let data = data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let query = json["query"] as? [String: Any],
                        let results = query["results"] as? [String: Any],
                        let channel = results["channel"] as? [String: Any],
                        let location = channel["location"] as? [String: Any] {
                    
                        if  let city = location["city"] as? String {
                        
                            OperationQueue.main.addOperation {
                                self.cityLabel.text = city
                            }
                        }
                    
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
                                let text = condition["text"] as? String,
                                let code = condition["code"] as? String {
                                
                                var image = ""
                                switch Int(code)! {
                                case 32, 34, 36:
                                    image = "sunnysky-340x275.png"
                                case 31, 33:
                                    image = "nightsky-340x275.png"
                                case 19, 20, 21, 22, 26, 28, 30, 44:
                                    image = "cloudysky-340x275.png"
                                case 27, 29:
                                    image = "cloudynightsky-340x275.png"
                                case 0, 1, 2, 3, 4, 9, 10, 11, 12, 37, 38, 39, 40, 45, 47:
                                    image = "rainningsky-340x275.png"
                                case 23, 24, 25:
                                    image = "windysky-340x275.png"
                                case 5, 6, 7, 8, 13, 14, 15, 16, 17, 18, 35, 41, 42, 43, 46:
                                    image = "snowsky-340x275.png"
                                default:
                                    image = "sunnysky-340x275.png"
                                }
                                print(code)
                            
                                OperationQueue.main.addOperation {
                                    self.tempLabel.text = self.temptranstion(temp: Double(temp)!) + "°"
                                    self.conditionLabel.text = text
                                    self.skyImageView?.image = UIImage(named: image)
                                }
                            }
                            
                            if  let forecasts = items["forecast"] as? NSArray {
                                
                                if self.forecastList.count != 0 {
                                    self.forecastList.removeAll()
                                }
                                for forecast in forecasts {
                                    if  let detail = forecast as? NSDictionary,
                                        let code = detail["code"] as? String,
                                        let date = detail["date"] as? String,
                                        let day = detail["day"] as? String,
                                        let high = detail["high"] as? String,
                                        let low = detail["low"] as? String,
                                        let text = detail["text"] as? String {
                                        
                                        let dayforecast = DayForecast(code: code, date: date, day: day, high: high, low: low, text: text)
                                        self.forecastList.append(dayforecast)
                                    }
                                }
                                OperationQueue.main.addOperation {
                                    self.forecastTable.reloadData()
                                    if self.refreshControl.isRefreshing {
                                        self.refreshControl.endRefreshing()
                                    }
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

extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "forecastCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WeatherTableVIewCell
        
        if forecastList.isEmpty {
            return cell
        }
        
        var day = forecastList[indexPath.row].day
        if indexPath.row == 0 {
            day = "Today"
        }
        
        var image = ""
        switch Int(forecastList[indexPath.row].code)! {
        case 32, 34, 36:
            image = "sunny-40x40"
        case 31:
            image = "clear-40x40"
        case 26:
            image = "cloudy-40x40.png"
        case 19, 20, 21, 22, 28, 30, 44:
            image = "mostly cloudy-40x40"
        case 27, 29:
            image = "cloudy-night-40x40"
        case 9, 10, 11, 12:
            image = "drizzle-40x40"
        case 0, 1, 2, 3, 4:
            image = "thunderstorms-40x40.png"
        case 37, 38, 39, 40, 45, 47:
            image = "scattered thunderstorms-40x40"
        case 23, 24, 25:
            image = "windy-40x40"
        case 33:
            image = "fair-night-40x40"
        case 5, 6, 7, 8, 13, 14, 15, 16, 17, 18, 35, 41, 42, 43, 46:
            image = "snow-40x30.png"
        default:
            image = "sunny=40x40.png"
        }
        
        cell.dayLabel.text = day
        cell.dateLabel.text = self.forecastList[indexPath.row].date
        cell.conditionImage.image = UIImage(named: image)
        cell.conditionImage.clipsToBounds = true
        cell.highLabel.text = self.temptranstion(temp: Double(self.forecastList[indexPath.row].high)!) + "°"
        cell.lowLabel.text = self.temptranstion(temp: Double(self.forecastList[indexPath.row].low)!) + "°"
        
        return cell
    }
}
