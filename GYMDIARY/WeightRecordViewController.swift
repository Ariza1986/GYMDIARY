//
//  WeightRecordViewController.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/5/19.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import UIKit

class WeightRecordViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var bodyFatTextField: UITextField!
    
    let weightPicker = UIPickerView()
    let bodyfatPicker = UIPickerView()
    
    var textFieldList:[UITextField]!
    var pickerViewList:[UIPickerView]!
    
    let weightPickerData = [Int](20...150)
    let bodyFatPickerData = [Int](1...60)
    let decimalsPickerData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    
    //catch date YYYYMMdd
    let today = Date()
    let formatter = DateFormatter()
    var todayStr:String?
    
    var weightData:(num:String, decimals:String)!
    var bodyFatData:(num:String, decimals:String)!
    
    var diaryData = DairyData()
    var trainerInfo = TrainerInfo()
    
    var myUserDefaults :UserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //⬇︎⬇︎--------ViewSetting----------⬇︎⬇︎
        //close keyboard by touching anywhere
        self.hideKeyboardWhenTappedAround()
        
        //⬇︎⬇︎--------DefaultValue---------⬇︎⬇︎
        //catch date YYYYMMdd
        formatter.dateFormat = "YYYY-MM-dd"
        todayStr = formatter.string(from: today)

        weightData = ("70", "0")
        bodyFatData = ("25", "0")
        
        diaryData.date = todayStr!
        
        myUserDefaults = UserDefaults.standard
        
        //⬇︎⬇︎--------UIView Setting-------⬇︎⬇︎
        textFieldList = [weightTextField, bodyFatTextField]
        pickerViewList = [weightPicker, bodyfatPicker]
        
        //textfields delegate & tag
        for (index, textField) in textFieldList.enumerated() {
            textField.delegate = self
            textField.tag = index + 1
        }
        
        //pickerview delegate & tag & inputview
        for (index, pickerView) in pickerViewList.enumerated() {
            pickerView.delegate = self
            pickerView.tag = index + 1
            textFieldList[index].inputView = pickerView
        }
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
            case 1:
                weightPicker.selectRow(Int(weightData.num)! - 20, inComponent: 0, animated: true)
                weightTextField.text = mergeData(data: weightData) + " kg"
                diaryData.data = Double(mergeData(data: weightData))!
                trainerInfo.weight.append(diaryData)
                
            case 2:
                bodyfatPicker.selectRow(Int(bodyFatData.num)! - 1, inComponent: 0, animated: true)
                bodyFatTextField.text = mergeData(data: bodyFatData) + " %"
                diaryData.data = Double(mergeData(data: bodyFatData))!
                trainerInfo.bodyFat.append(diaryData)
                
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
    }
    
    //⬇︎⬇︎--------PickerView Delegate----------⬇︎⬇︎
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            if component == 0 {
                return weightPickerData.count
            }
            else {
                return decimalsPickerData.count
            }
            
        case 2:
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
        case 1:
            if component == 0 {
                return String(weightPickerData[row]) + " ."
            }
            else {
                return String(decimalsPickerData[row]) + " kg"
            }
            
        case 2:
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
        case 1:
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
            
        case 2:
            if component == 0 {
                bodyFatData.num = String(bodyFatPickerData[row])
            }
            else {
                bodyFatData.decimals = String(decimalsPickerData[row])
            }
            bodyFatTextField.text = mergeData(data: bodyFatData) + " ％"
            diaryData.data = Double(mergeData(data: bodyFatData))!
            trainerInfo.bodyFat.removeAll()
            trainerInfo.bodyFat.append(diaryData)
            
        default: break
        }
    }
    //pickerview width for component
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 66.0
    }

    //⬇︎⬇︎--------Button Event----------⬇︎⬇︎
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
    
}
