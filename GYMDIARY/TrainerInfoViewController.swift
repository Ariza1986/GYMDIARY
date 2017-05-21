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

struct DairyData {
    var Date = ""
    var Data = 0.0
}

class TrainerInfo {
    var name:String = ""
    var sex:Sex = Sex.Male
    var birthDay:String = ""
    var height:Double = 0.0
    var weight:[DairyData] = []
    var bodyFat:[DairyData] = []
    
    func showAll() {
        print("trainerName:\t" + "\(name)" + "\n" +
              "trainerSex:\t" + "\(sex)" + "\n" +
              "birthDay:\t" + "\(birthDay)" + "\n" +
              "height:\t\t" + "\(height)" + "\n" +
              "weight:\t\t" + "\(weight)" + "\n" +
              "bodyFat:\t\t" + "\(bodyFat)")
    }
}

class TrainerInfoViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sexTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var bodyfatTextField: UITextField!
    
    let sexPicker = UIPickerView()
    let birthdayPicker = UIPickerView()
    let heightPicker = UIPickerView()
    let weightPicker = UIPickerView()
    let bodyfatPicker = UIPickerView()
    
    let myPickerData = ["♂", "♀"]

    var trainerInfo = TrainerInfo()
    let myUserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //close keyboard by touching anywhere
        self.hideKeyboardWhenTappedAround()
        
        // handle the user input in the text fields through delegate callbacks
        nameTextField.delegate = self
        sexTextField.delegate = self
        birthdayTextField.delegate = self
        heightTextField.delegate = self
        weightTextField.delegate = self
        bodyfatTextField.delegate = self
        
        // tags
        nameTextField.tag = 1
        sexTextField.tag = 2
        birthdayTextField.tag = 3
        heightTextField.tag = 4
        weightTextField.tag = 5
        bodyfatTextField.tag = 6
        
        sexPicker.delegate = self
        birthdayPicker.delegate = self
        heightPicker.delegate = self
        weightPicker.delegate = self
        bodyfatPicker.delegate = self
        
        sexPicker.tag = 2
        birthdayPicker.tag = 3
        heightPicker.tag = 4
        weightPicker.tag = 5
        bodyfatPicker.tag = 6
        
        sexTextField.inputView = sexPicker
        birthdayTextField.inputView = birthdayPicker
        heightTextField.inputView = heightPicker
        weightTextField.inputView = weightPicker
        bodyfatTextField.inputView = bodyfatPicker
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // User finished typing (hit return): hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 1:
            if (textField.text?.isEmpty)! {
                textField.backgroundColor = UIColor.init(red:0.98, green:0.29, blue:0.29, alpha:0.6)
                //textField.layer.borderColor = UIColor.red.cgColor
                //textField.layer.borderWidth = 1.5
            }
            else {
                textField.backgroundColor = UIColor.white
                trainerInfo.name = textField.text!
            }
        case 2: break
            
        case 3: break
            
        case 4: break
            
        case 5: break
            
        case 6: break

        default: break
        }
    }
    
    //PickerView Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myPickerData[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 2:
            if row == 0{
                sexTextField.text = myPickerData[row]
                trainerInfo.sex = .Male
            }
            else{
                sexTextField.text = myPickerData[row]
                trainerInfo.sex = .Female
            }
            
        case 3: break
            
        case 4: break
            
        case 5: break
            
        case 6: break
            
        default: break
        }
    }
    
    //Button Event
    @IBAction func pressOkButton() {
        trainerInfo.showAll()
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}
