//
//  AddWorkoutViewController.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/6/5.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import UIKit

class AddWorkoutViewController: UIViewController {
   
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var workoutDatePicker: UIDatePicker!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var setsTextField: UITextField!
    @IBOutlet weak var repsTextField: UITextField!
    @IBOutlet weak var kgTextField: UITextField!
    
    let categoryPicker = UIPickerView()
    let itemPicker = UIDatePicker()
    let setsPicker = UIPickerView()
    let repsPicker = UIPickerView()
    let kgPicker = UIPickerView()
    
    var textFieldList:[UITextField]!
    var pickerViewList:[UIPickerView]!

    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        
        //⬇︎⬇︎--------ViewSetting----------⬇︎⬇︎
        //close keyboard by touching anywhere
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.1, animations: {
        self.containerView.transform = CGAffineTransform.identity
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
