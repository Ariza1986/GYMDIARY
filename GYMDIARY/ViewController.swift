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
    
    var myUserDefaults :UserDefaults!
    
    var info:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        myUserDefaults = UserDefaults.standard
        
        info = myUserDefaults.string(forKey: "name")
        
        if info != nil {
            trainerName.text = info
        }
        else {
            trainerName.text = "尚未儲存資訊"
            trainerName.textColor = UIColor.red
        }
        
        DispatchQueue.main.async {
            if self.info == nil {
                self.performSegue(withIdentifier: "goToTrainerInfo", sender: self)
            }
            else {
                self.performSegue(withIdentifier: "goToWeightRecord", sender: self)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func catchNewTrainerInfo() {
        myUserDefaults.removeObject(forKey: "name")
        
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
    
    func mergeData(data : (num:String, decimals:String)) -> String {
        return "\(data.num)" + "." + "\(data.decimals)"
    }
}

