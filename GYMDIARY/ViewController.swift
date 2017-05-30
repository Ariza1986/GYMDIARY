//
//  ViewController.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/5/2.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController{
    
    @IBOutlet weak var trainerName: UILabel!
    
    var info = TrainerInfo()
    var myUserDefaults = UserDefaults()
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //get info
        if let data = UserDefaults.standard.data(forKey: "info"),
            let trainerInfo = NSKeyedUnarchiver.unarchiveObject(with: data) as? TrainerInfo {
            info = trainerInfo
        } else {
            print("show new trainer info view")
        }

        if info.name != "" { //go Scale View
            trainerName.text = info.name
            //info.showAll()
        }
        else {//go New Trainer Info
            trainerName.text = "尚未儲存資訊"
            trainerName.textColor = UIColor.red
        }
        
        formatter.dateFormat = "YYYY-MM-dd"
        let today = formatter.string(from: info.today)
        
        DispatchQueue.main.async {
            if self.info.name == "" {
                self.performSegue(withIdentifier: "goToTrainerInfo", sender: self)
            }
            else if today != self.formatter.string(from: Date()) {
                self.performSegue(withIdentifier: "goToWeightRecord", sender: self)
            }
        }
    }

    @IBAction func resetTrainerInfo() {
        myUserDefaults.removeObject(forKey: "info")
        myUserDefaults.synchronize()
        
        //let realm = try! Realm()
        //try! realm.write {
        //    realm.deleteAll()
        //}
        
        trainerName.text = "尚未儲存資訊"
        trainerName.textColor = UIColor.red
    }
    
    func typeYourWeight() {
        let alertController = UIAlertController(title: "Waring!!",
                                                message: "What's your Weight today?",
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK",
                                                style:UIAlertActionStyle.default,
                                                handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//close keyboard by touching anywhere
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func mergeData(data : (num:Int, decimals:Int)) -> Double {
        return Double("\(data.num)" + "." + "\(data.decimals)")!
    }
}

extension Date {
    
    /// Returns a Date with the specified days added to the one it is called with
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
        var targetDay: Date
        targetDay = Calendar.current.date(byAdding: .year, value: years, to: self)!
        targetDay = Calendar.current.date(byAdding: .month, value: months, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .day, value: days, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .hour, value: hours, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .minute, value: minutes, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .second, value: seconds, to: targetDay)!
        return targetDay
    }
    
    /// Returns a Date with the specified days subtracted from the one it is called with
    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
        let inverseYears = -1 * years
        let inverseMonths = -1 * months
        let inverseDays = -1 * days
        let inverseHours = -1 * hours
        let inverseMinutes = -1 * minutes
        let inverseSeconds = -1 * seconds
        return add(years: inverseYears, months: inverseMonths, days: inverseDays, hours: inverseHours, minutes: inverseMinutes, seconds: inverseSeconds)
    }
    
}
