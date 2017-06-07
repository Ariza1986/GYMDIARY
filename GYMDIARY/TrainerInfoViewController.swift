//
//  TrainerInfoViewController.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/5/18.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import UIKit
import RealmSwift

class TrainerInfoViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sexTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var bodyfatTextField: UITextField!
    
    let sexPicker = UIPickerView()
    let birthdayPicker = UIDatePicker()
    let heightPicker = UIPickerView()
    let weightPicker = UIPickerView()
    let bodyfatPicker = UIPickerView()
    
    var textFieldList:[UITextField]!
    var pickerViewList:[UIPickerView]!
    
    let sexPickerData = ["♂", "♀"]
    let heightPickerData = [Int](130...250)
    let weightPickerData = [Int](20...150)
    let bodyFatPickerData = [Int](1...60)
    let decimalsPickerData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

    
    //catch date YYYYMMdd
    let today = Date()
    let formatter = DateFormatter()
    var todayStr:String?
    
    var heightData:(num:Int, decimals:Int)!
    var weightData:(num:Int, decimals:Int)!
    var bodyFatData:(num:Int, decimals:Int)!
    
    let info = TrainerInfo()
    var myUserDefaults :UserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //⬇︎⬇︎--------ViewSetting----------⬇︎⬇︎
        //close keyboard by touching anywhere
        self.hideKeyboardWhenTappedAround()
        
        //⬇︎⬇︎--------DefaultValue---------⬇︎⬇︎
        //catch date YYYYMMdd
        formatter.dateFormat = "YYYY-MM-dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        todayStr = formatter.string(from: today)
        
        heightData = (170, 0)
        weightData = (70, 0)
        bodyFatData = (25, 0)
        
        myUserDefaults = UserDefaults.standard
        
        //⬇︎⬇︎--------UIView Setting-------⬇︎⬇︎
        textFieldList = [nameTextField, sexTextField, birthdayTextField,
                         heightTextField, weightTextField, bodyfatTextField]
        pickerViewList = [sexPicker, heightPicker, weightPicker, bodyfatPicker]
        
        //textfields delegate & tag
        for (index, textField) in textFieldList.enumerated() {
            textField.delegate = self
            textField.tag = index + 1
        }
        
        //pickerview delegate & tag & inputview
        for (index, pickerView) in pickerViewList.enumerated() {
            pickerView.delegate = self
            
            if index != 0 {
                textFieldList[index + 2].inputView = pickerView
                pickerView.tag = index + 3
            }
            else{
                textFieldList[index + 1].inputView = pickerView
                pickerView.tag = index + 2
            }
        }
        
        //date pickerview
        birthdayPicker.datePickerMode = .date
        birthdayPicker.date = Date().subtract(years: 20)
        birthdayPicker.minimumDate = formatter.date(from: "1930-01-01")
        birthdayPicker.maximumDate = formatter.date(from: todayStr!)
        birthdayPicker.locale = Locale(identifier: "zh_TW")
        birthdayTextField.inputView = birthdayPicker
        birthdayPicker.addTarget(self, action: #selector(self.datePickerChanged),for: .valueChanged)
    }
    
    //⬇︎⬇︎--------UITextFieldDelegate----------⬇︎⬇︎
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
                info.sex = sexPickerData[0]
            
            case 3:
                birthdayTextField.text = todayStr!
                info.birthDay = todayStr!
            
            case 4:
                heightPicker.selectRow(heightData.num - 130, inComponent: 0, animated: true)
                heightTextField.text = String(mergeData(data: heightData)) + " cm"
                info.height = mergeData(data: heightData)
            
            case 5:
                weightPicker.selectRow(weightData.num - 20, inComponent: 0, animated: true)
                weightTextField.text = String(mergeData(data: weightData)) + " kg"
                info.weight = mergeData(data: weightData)
            
            case 6:
                bodyfatPicker.selectRow(bodyFatData.num - 1, inComponent: 0, animated: true)
                bodyfatTextField.text = String(mergeData(data: bodyFatData)) + " %"
                info.bodyFat = mergeData(data: bodyFatData)
            
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
            info.name = textField.text!

        default: break
        }
    }
    
    //⬇︎⬇︎--------PickerView Delegate----------⬇︎⬇︎
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView.tag {
        case 4, 5, 6:
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
            
        case 6:
            if component == 0 {
                return bodyFatPickerData.count
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
            
        case 6:
            if component == 0 {
                return String(bodyFatPickerData[row]) + " ."
            }
            else {
                return String(decimalsPickerData[row]) + " %"
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
                info.sex = sexPickerData[row]
            }
            else{
                sexTextField.text = sexPickerData[row]
                info.sex = sexPickerData[row]
            }
            
        case 4:
            if component == 0 {
                heightData.num = heightPickerData[row]
            }
            else {
                heightData.decimals = decimalsPickerData[row]
            }
            heightTextField.text = String(mergeData(data: heightData)) + " cm"
            info.height = mergeData(data: heightData)

        case 5:
            if component == 0 {
                weightData.num = weightPickerData[row]
            }
            else {
                weightData.decimals = decimalsPickerData[row]
            }
            weightTextField.text = String(mergeData(data: weightData)) + " kg"
            info.weight = mergeData(data: weightData)
            
        case 6:
            if component == 0 {
                bodyFatData.num = bodyFatPickerData[row]
            }
            else {
                bodyFatData.decimals = decimalsPickerData[row]
            }
            bodyfatTextField.text = String(mergeData(data: bodyFatData)) + " ％"
            info.bodyFat = mergeData(data: bodyFatData)

        default: break
        }
    }
    //pickerview width for component
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 66.0
    }
    
    //⬇︎⬇︎--------UIDatePicker----------⬇︎⬇︎
    func datePickerChanged(datePicker:UIDatePicker) {
        let newDate = formatter.string(from: datePicker.date)
        birthdayTextField.text = newDate
        info.birthDay = newDate
    }
    
    //⬇︎⬇︎--------Button Event----------⬇︎⬇︎
    @IBAction func pressOkButton() {
        
        var flag = true
        
        for textField in textFieldList {
            if textField.text == "" {
                textField.isEmptyField()
                flag = false
            }
        }
        if flag == true {
            info.today = Date()
            
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: info)
            UserDefaults.standard.set(encodedData, forKey: "info")
            myUserDefaults.synchronize()
            
            info.showAll()
            
            //db writeData
            writeDairyRecord()
            self.performSegue(withIdentifier: "newTrainerInfoBackTo", sender: self)
        }
    }
    
    //⬇︎⬇︎--------RLM_DB----------⬇︎⬇︎
    func writeDairyRecord() {
        let realm = try! Realm()
        let dairyRecord = RLM_DairyRecord()
        
        dairyRecord.date = NSDate()
        dairyRecord.weight = info.weight
        dairyRecord.bodyFat = info.bodyFat
        
        try! realm.write {
            realm.add(dairyRecord)
            
            print("DB write success")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
