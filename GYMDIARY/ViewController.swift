//
//  ViewController.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/5/2.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    
    var trainerInfo = TrainerInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //let myUserDefaults = UserDefaults.standard
        
        //catch date YYYYMMdd
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMdd"
        print(today)
        print(formatter.string(from: today))
        
        DispatchQueue.main.async {
        //print("This is run on the main queue, after the previous code in outer block")
            //self.typeYourWeight()
            self.performSegue(withIdentifier: "goToTrainerInfo", sender: self)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func catchNewTrainerInfo() {

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

