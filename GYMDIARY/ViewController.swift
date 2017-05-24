//
//  ViewController.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/5/2.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import UIKit

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
            print("There is an issue")
        }

        if info.name != "" {
            trainerName.text = info.name
        }
        else {
            trainerName.text = "尚未儲存資訊"
            trainerName.textColor = UIColor.red
        }
        
        formatter.dateFormat = "YYYY-MM-dd hh:mm"
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func resetTrainerInfo() {
        myUserDefaults.removeObject(forKey: "info")
        myUserDefaults.synchronize()
        
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

