//
//  ViewController.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/5/2.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //let myUserDefaults = UserDefaults.standard
        
        //catch date YYYYMMdd
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMdd"
        print(formatter.string(from: now))
        
        DispatchQueue.main.async {
        //print("This is run on the main queue, after the previous code in outer block")
            self.typeYourWeight()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func typeYourWeight() {
        let alertController = UIAlertController(title: "Waring!!",
                                                message: "What's your Weight today?",
                                                preferredStyle: UIAlertControllerStyle.alert)
        /*
        alertController.addTextField { (textField1) in
            textField1.text = "Weight Today"
            textField1.keyboardType = UIKeyboardType.numbersAndPunctuation
        }
        
        alertController.addTextField { (textField2) in
            textField2.text = "Body Fat % Today"
            textField2.keyboardType = UIKeyboardType.numbersAndPunctuation
        }
        */
        alertController.addAction(UIAlertAction(title: "OK",
                                                style:UIAlertActionStyle.default,
                                                handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

