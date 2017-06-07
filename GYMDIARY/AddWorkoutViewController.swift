//
//  AddWorkoutViewController.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/6/5.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import UIKit

enum Category: Int {
    case Core = 0
    case Aerobic
    case Chest
    case Back
    case Leg
    case Arm
}

struct WorkoutSet {
    var uuid:String
    var sets:Int
    var reps:Int
    var mins:Int
    var secs:Int
    var kg:Double
    var km:Double
    
    init() {
        uuid = ""
        sets = 1
        reps = 1
        mins = 0
        secs = 0
        kg = 0.0
        km = 0.1
    }
    
    func showAll() {
        print("uuid:\t\(uuid)")
        print("sets:\t\t\(sets)")
        print("reps:\t\t\(reps)")
        print("mins:\t\t\(mins)")
        print("secs:\t\t\(secs)")
        print("kg:\t\t\t\(kg)")
        print("km:\t\t\t\(km)")
    }
}

class AddWorkoutViewController: UIViewController {
   
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var workoutDatePicker: UIDatePicker!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var setsTextField: UITextField!
    @IBOutlet weak var repsTextField: UITextField!
    @IBOutlet weak var kgTextField: UITextField!
    
    @IBOutlet weak var setsLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var kgLabel: UILabel!
    
    let categoryPicker = UIPickerView()
    let itemPicker = UIPickerView()
    let setsPicker = UIPickerView()
    let repsPicker = UIPickerView()
    let kgPicker = UIPickerView()
    
    var textFieldList:[UITextField]!
    var pickerViewList:[UIPickerView]!
    
    let categoryPickerData = ["Core", "Aerobic", "Chest", "Back", "Leg", "Arm"]
    
    let coreItemPickerData = ["Plank", "Side Plank", "Curl-up", "Leg Raise", "Roller Slide"]
    let aerobicItemPickerData = ["Running", "Swimming"]
    let chestItemPickerData = ["Push-up", "Smith Machine Press", "Strength Machine Press", "Dumbbell Bench Press", "Barbell Bench Press", "Standing Cable"]
    let backItemPickerData = ["Front Pull-Down", "Barbell Bent Rows", "Pully Rowing", "Front Chin-ups", "Hyperextensions"]
    let legItemPickerData = ["Squat", "Smith Machine Squat", "Barbell Squat"]
    let armItemPickerData = ["Straight Bar Arm Curl", "Cable Standing Curl", "Dumbbells Curl", "Triceps Pushdown",
                             "Dumbbell Extension", "Lateral Raise", "Front lateral Raise", "Standing Barbell Press",
                             "Dumbell Shoulder Press"]
    
    let setsPickerData = [Int](1...100)
    let repsPickerData = [Int](1...200)
    var kgPickerData = [0.0]
    let kmPickerData = [Int](1...1000)
    let minsPickerData = [Int](0...500)
    let secsPickerData = [Int](0...60)
    
    let formatter = DateFormatter()
    var selectedDay:Date!
    var category:Category = .Core
    var item:String = ""
    var workoutSet = WorkoutSet()
    var workoutSets = [WorkoutSet]()
    var setStatus = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initial kgPickerData
        for index in 1...2000 {
            kgPickerData.append(kgPickerData[index-1] + 0.25)
        }
        
        //for animations
        containerView.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        
        //⬇︎⬇︎--------ViewSetting----------⬇︎⬇︎
        //close keyboard by touching anywhere
        self.hideKeyboardWhenTappedAround()
        
        textFieldList = [categoryTextField, itemTextField, setsTextField, repsTextField, kgTextField]
        pickerViewList = [categoryPicker, itemPicker, setsPicker, repsPicker, kgPicker]
        
        //textfields delegate & tag
        for (index, textField) in textFieldList.enumerated() {
            textField.delegate = self
            textField.tag = index + 1
        }
        
        //pickerview delegate & tag & inputview
        for (index, pickerView) in pickerViewList.enumerated() {
            pickerView.delegate = self
            textFieldList[index].inputView = pickerView
            pickerView.tag = index + 1
        }
        
        //⬇︎⬇︎--------DateSetting----------⬇︎⬇︎
        formatter.dateFormat = "YYYY-MM-dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        workoutDatePicker.date = selectedDay
        workoutDatePicker.locale = Locale(identifier: "zh_TW")
        print(formatter.string(from: selectedDay))
        workoutDatePicker.addTarget(self, action: #selector(self.datePickerChanged),for: .valueChanged)
    }
    
    func changeSetType(type: Int) {
        if setStatus != type {//change set type
            setStatus = type
            
            setsTextField.text?.removeAll()
            repsTextField.text?.removeAll()
            kgTextField.text?.removeAll()
            setsPicker.selectRow(0, inComponent: 0, animated: true)
            repsPicker.selectRow(0, inComponent: 0, animated: true)
            kgPicker.selectRow(0, inComponent: 0, animated: true)
            
            workoutSet = WorkoutSet()
            workoutSets.removeAll()
        }
        switch type {
        case 1:
            setsLabel.text = "sets"
            repsLabel.text = "reps"
            kgLabel.text = "kg"
            setsTextField.placeholder = "sets"
            repsTextField.placeholder = "reps"
            kgTextField.placeholder = "KG"
        case 2:
            setsLabel.text = "KM"
            repsLabel.text = "mins"
            kgLabel.text = "secs"
            setsTextField.placeholder = "KM"
            repsTextField.placeholder = "mins"
            kgTextField.placeholder = "secs"
        case 3:
            setsLabel.text = "sets"
            repsLabel.text = "mins"
            kgLabel.text = "secs"
            setsTextField.placeholder = "sets"
            repsTextField.placeholder = "mins"
            kgTextField.placeholder = "secs"
        default:
            print("Error:changeSetType")
        }
    }
    
    func datePickerChanged(datePicker:UIDatePicker) {
       selectedDay = datePicker.date
    }
    
    @IBAction func addWorkoutSet() {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        print("")
        print("date:\t\t\(formatter.string(from: selectedDay))")
        print("category:\t\(category)")
        print("item:\t\t\(item)")
        print("setStatus:\t\(setStatus)")
        workoutSet.showAll()
    }
    
    @IBAction func addWorkoutSets() {
        workoutSet.showAll()
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

extension AddWorkoutViewController:  UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // User finished typing (hit return): hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            switch textField.tag {
            case 1:
                categoryTextField.text = categoryPickerData[0] + ":"
            case 2:
                if !(categoryTextField.text?.isEmpty)! {
                    switch category {
                    case .Core:
                        itemTextField.text = coreItemPickerData[0]
                        item = coreItemPickerData[0]
                        changeSetType(type: 3)
                    case .Aerobic:
                        itemTextField.text = aerobicItemPickerData[0]
                        item = aerobicItemPickerData[0]
                        changeSetType(type: 2)
                    case .Chest:
                        itemTextField.text = chestItemPickerData[0]
                        item = chestItemPickerData[0]
                        changeSetType(type: 1)
                    case .Back:
                        itemTextField.text = backItemPickerData[0]
                        item = backItemPickerData[0]
                        changeSetType(type: 1)
                    case .Leg:
                        itemTextField.text = legItemPickerData[0]
                        item = legItemPickerData[0]
                        changeSetType(type: 1)
                    case .Arm:
                        itemTextField.text = armItemPickerData[0]
                        item = armItemPickerData[0]
                        changeSetType(type: 1)
                    }
                }
            case 3:
                if !(itemTextField.text?.isEmpty)! {
                    switch setStatus {
                    case 1, 3:  //for sets
                        setsTextField.text = "1"
                    case 2:     //for KM
                        setsTextField.text = "0.1"
                    default:
                        print("Error:setsTextField")
                    }
                }
            case 4:
                if !(itemTextField.text?.isEmpty)! {
                    switch setStatus {
                    case 1:     //for reps
                        repsTextField.text = "1"
                    case 2, 3:  //for mins
                        repsTextField.text = "0"
                    default:
                        print("Error:repsTextField")
                    }
                }
            case 5:
                if !(itemTextField.text?.isEmpty)! {
                    switch setStatus {
                    case 1:   //for KG
                        kgTextField.text = "0"
                    case 2, 3://for secs
                        kgTextField.text = "0"
                    default:
                        print("Error:kgTextField")
                    }
                }
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
}

extension AddWorkoutViewController:UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView.tag {
        case 1, 2:
            return 1
        default:
            return 1
        }
    }
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return categoryPickerData.count
        case 2:
            if !(categoryTextField.text?.isEmpty)! {
                switch category {
                case .Core:
                    return coreItemPickerData.count
                case .Aerobic:
                    return aerobicItemPickerData.count
                case .Chest:
                    return chestItemPickerData.count
                case .Back:
                    return backItemPickerData.count
                case .Leg:
                    return legItemPickerData.count
                case .Arm:
                    return armItemPickerData.count
                }
            }
            else {
                return 0
            }
        default:
            return 0
        }
    }
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return categoryPickerData[row]
        case 2:
            switch category {
            case .Core:
                return coreItemPickerData[row]
            case .Aerobic:
                return aerobicItemPickerData[row]
            case .Chest:
                return chestItemPickerData[row]
            case .Back:
                return backItemPickerData[row]
            case .Leg:
                return legItemPickerData[row]
            case .Arm:
                return armItemPickerData[row]
            }
        default:
            return "Error:titleForRow"
        }
    }
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            categoryTextField.text = categoryPickerData[row] + ":"
            //change category clear item and set default
            itemTextField.text?.removeAll()
            itemPicker.selectRow(0, inComponent: 0, animated: true)

            category = Category(rawValue: row)!
        case 2:
            if !(categoryTextField.text?.isEmpty)! {
                switch category {
                case .Core:
                    itemTextField.text = coreItemPickerData[row]
                    item = coreItemPickerData[0]
                    if row <= 1 {   //for Plank, Side Plank
                        changeSetType(type: 3)
                    }
                    else {          //for Curl-ups, Leg Raise, Roller Slide
                        changeSetType(type: 1)
                    }
                case .Aerobic:
                    itemTextField.text = aerobicItemPickerData[row]
                    item = aerobicItemPickerData[0]
                    changeSetType(type: 2)
                case .Chest:
                    itemTextField.text = chestItemPickerData[row]
                    item = chestItemPickerData[0]
                    changeSetType(type: 1)
                case .Back:
                    itemTextField.text = backItemPickerData[row]
                    item = backItemPickerData[0]
                    changeSetType(type: 1)
                case .Leg:
                    itemTextField.text = legItemPickerData[row]
                    item = legItemPickerData[0]
                    changeSetType(type: 1)
                case .Arm:
                    itemTextField.text = armItemPickerData[row]
                    item = armItemPickerData[0]
                    changeSetType(type: 1)
                }
            }
        default:
            print("Error:didSwlectRow")
        }
    }
    //pickerview width for component
    //func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
    //    return 100.0
    //}

}

extension AddWorkoutViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "setCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = "123"
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    }
}

