//
//  TrainerInfoViewController.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/5/18.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import UIKit

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
    
    var textFieldList:[UITextField]!
    var pickerViewList:[UIPickerView]!
    
    //catch date YYYYMMdd
    var todayStr:String?
    
    let sexPickerData = ["♂", "♀"]
    let heightPickerData = [Int](130...250)
    let weightPickerData = [Int](20...150)
    let bodyFatPickerData = [Int](1...60)
    let decimalsPickerData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

    var heightData:(num:String, decimals:String)!
    var weightData:(num:String, decimals:String)!
    var bodyFatData:(num:String, decimals:String)!
    var diaryData = DairyData()
    
    var trainerInfo = TrainerInfo()
    let myUserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //⬇︎⬇︎------SomeViewSetting--------⬇︎⬇︎
        //close keyboard by touching anywhere
        self.hideKeyboardWhenTappedAround()
        
        //⬇︎⬇︎--------DefaultValue---------⬇︎⬇︎
        //catch date YYYYMMdd
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMdd"
        todayStr = formatter.string(from: today)
        
        heightData = ("170", "0")
        weightData = ("70", "0")
        bodyFatData = ("25", "0")
        diaryData.date = todayStr!
        
        //⬇︎⬇︎----------UIView-------------⬇︎⬇︎
        textFieldList = [nameTextField, sexTextField, birthdayTextField,
                         heightTextField, weightTextField, bodyfatTextField]
        pickerViewList = [sexPicker, birthdayPicker, heightPicker, weightPicker, bodyfatPicker]
        
        //textfields delegate & tag
        for (index, textField) in textFieldList.enumerated() {
            textField.delegate = self
            textField.tag = index + 1
        }
        
        //pickerview delegate & tag & inputview
        for (index, pickerView) in pickerViewList.enumerated() {
            pickerView.delegate = self
            pickerView.tag = index + 2
            textFieldList[index + 1].inputView = pickerView
        }
    }
    
    // UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // User finished typing (hit return): hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            switch textField.tag {
            case 2:
                sexTextField.text = sexPickerData[0]
                trainerInfo.sex = .Male
            
            case 3: break
            
            case 4:
                for (index, height) in heightPickerData.enumerated() {
                    if height == Int(heightData.num) {
                        heightPicker.selectRow(index, inComponent: 0, animated: true)
                    }
                }
                heightTextField.text = mergeData(data: heightData) + " cm"
                trainerInfo.height = Double(mergeData(data: heightData))!
            
            case 5:
                for (index, weight) in weightPickerData.enumerated() {
                    if weight == Int(weightData.num) {
                        weightPicker.selectRow(index, inComponent: 0, animated: true)
                    }
                }
                weightTextField.text = mergeData(data: weightData) + " kg"
                diaryData.data = Double(mergeData(data: weightData))!
                trainerInfo.weight.append(diaryData)
            
            case 6: break
            
            default: break
            }
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            textField.isEmptyField()
        }
        else {
            textField.isNonEmptyField()
        }
        
        switch textField.tag {
        case 1:
            trainerInfo.name = textField.text!

        default: break
        }
    }
    
    //PickerView Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView.tag {
        case 4, 5:
            return 2
            
        default:
            return 1
        }
    }
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 2:
            return sexPickerData.count
            
        case 4:
            if component == 0 {
                return heightPickerData.count
            }
            else {
                return decimalsPickerData.count
            }
            
        case 5:
            if component == 0 {
                return weightPickerData.count
            }
            else {
                return decimalsPickerData.count
            }

        default:
            return 0
        }
    }
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 2:
            return sexPickerData[row]
            
        case 4:
            if component == 0 {
                return String(heightPickerData[row]) + " ."
            }
            else {
                return String(decimalsPickerData[row]) + " cm"
            }
            
        case 5:
            if component == 0 {
                return String(weightPickerData[row]) + " ."
            }
            else {
                return String(decimalsPickerData[row]) + " kg"
            }
            
        default:
            return ""
        }
        
    }
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        case 2:
            if row == 0{
                sexTextField.text = sexPickerData[row]
                trainerInfo.sex = .Male
            }
            else{
                sexTextField.text = sexPickerData[row]
                trainerInfo.sex = .Female
            }
            
        case 3: break
            
        case 4:
            if component == 0 {
                heightData.num = String(heightPickerData[row])
            }
            else {
                heightData.decimals = String(decimalsPickerData[row])
            }
            heightTextField.text = mergeData(data: heightData) + " cm"
            trainerInfo.height = Double(mergeData(data: heightData))!

        case 5:
            if component == 0 {
                weightData.num = String(weightPickerData[row])
            }
            else {
                weightData.decimals = String(decimalsPickerData[row])
            }
            weightTextField.text = mergeData(data: weightData) + " kg"
            diaryData.data = Double(mergeData(data: weightData))!
            trainerInfo.weight.removeAll()
            trainerInfo.weight.append(diaryData)
            
        case 6: break
            
        default: break
        }
    }
    //pickerview width for component
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 66.0
    }
    
    //Button Event
    @IBAction func pressOkButton() {
        trainerInfo.showAll()
        
        var flag = true
        
        for textField in textFieldList {
            if textField.text == "" {
                textField.isEmptyField()
                flag = false
            }
        }
        if flag == true {
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mergeData(data : (num:String, decimals:String)) -> String {
        return "\(data.num)" + "." + "\(data.decimals)"
    }
}

extension UITextField {
    func isEmptyField() {
        //textField.backgroundColor = UIColor.init(red:0.98, green:0.29, blue:0.29, alpha:0.6)
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1.5
        self.layer.cornerRadius = 5.0
    }
    func isNonEmptyField() {
        self.layer.borderColor = UIColor.clear.cgColor
    }
}
