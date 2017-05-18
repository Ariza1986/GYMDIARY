//
//  TrainerInfoViewController.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/5/18.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import UIKit

enum Sex {
    case Male
    case Female
}

struct TrainerInfo {
    var trainerName:String = ""
    var trainerSex:Sex = Sex.Male
    var birthDay:String = ""
    var height:Double = 0.0
    var weight:Double = 0.0
    var bodyFat:Double = 0.0
}

class TrainerInfoViewController: UIViewController{
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sexTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var bodyfatTextField: UITextField!

    var trainerInfo = TrainerInfo()
    let myUserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressOkButton() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}
