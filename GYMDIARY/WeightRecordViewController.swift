//
//  WeightRecordViewController.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/5/19.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class WeightRecordViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var bodyFatTextField: UITextField!
    @IBOutlet weak var combinedChartView: CombinedChartView!
    @IBOutlet weak var chartViewSegCtrl: UISegmentedControl!

    let weightPicker = UIPickerView()
    let bodyfatPicker = UIPickerView()
    
    //for TextField
    var textFieldList:[UITextField]!
    var pickerViewList:[UIPickerView]!
    
    //for PickerView
    let weightPickerData = [Int](20...150)
    let bodyFatPickerData = [Int](1...60)
    let decimalsPickerData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    
    var weightData:(num:Int, decimals:Int)!
    var bodyFatData:(num:Int, decimals:Int)!
    
    //for ChartView
    var dateList: [String]! = []
    var weightValueList: [Double]! = []
    var bodyFatValueList: [Double]! = []
    
    //catch date YYYYMMdd
    let today = Date()
    let formatter = DateFormatter()
    var todayStr:String?
    
    var info:TrainerInfo!
    var myUserDefaults :UserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //⬇︎⬇︎--------ViewSetting----------⬇︎⬇︎
        //close keyboard by touching anywhere
        self.hideKeyboardWhenTappedAround()
        
        //⬇︎⬇︎--------DefaultValue---------⬇︎⬇︎
        //catch date YYYYMMdd
        formatter.dateFormat = "MM/dd"
        todayStr = formatter.string(from: today)
        
        myUserDefaults = UserDefaults.standard
        
        if let data = UserDefaults.standard.data(forKey: "info"),
            let trainerInfo = NSKeyedUnarchiver.unarchiveObject(with: data) as? TrainerInfo {
            info = trainerInfo
        }
        
        let wDecimals = Int(info.weight * 10) % 10
        let bDecimals = Int(info.bodyFat * 10) % 10
        weightData = (Int(info.weight), wDecimals)
        bodyFatData = (Int(info.bodyFat), bDecimals)
        
        weightTextField.placeholder = String(info.weight) + " kg"
        bodyFatTextField.placeholder = String(info.bodyFat) + " %"
        
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
        
        //⬇︎⬇︎----------ChartView----------⬇︎⬇︎
        combinedChartView.backgroundColor = UIColor.white
        combinedChartView.xAxis.labelPosition = .bottom
        combinedChartView.chartDescription?.text = "week"
        combinedChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        getChartDataList(before: "week")
        setChart(chartType: "bar")
        
        //⬇︎⬇︎--------Segmented Ctrl-------⬇︎⬇︎
        chartViewSegCtrl.addTarget(self,action: #selector(onChange),for: .valueChanged)
        
        //dateList = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan"]
        //weightValueList = [90.6, 85.1, 80.8, 73.0, 71.8, 74.0, 0.0, 74.3, 73.8, 74.8, 75.7, 75.9, 76.0]
        //bodyFatValueList = [35.3, 27.1, 0.0, 19.3, 15.5, 13.4, 13.9, 13.5, 13.4, 12.4, 11.2, 10.8, 10.5]
        //setChart(dateList: dateList, weightValueList: weightValueList, bodyFatValueList: bodyFatValueList)
    }
    
    //⬇︎⬇︎------------Segmented Ctrl-----------⬇︎⬇︎
    func onChange(sender: UISegmentedControl) {
        dateList.removeAll()
        weightValueList.removeAll()
        bodyFatValueList.removeAll()
        
        switch sender.selectedSegmentIndex {
        case 0:
            getChartDataList(before: "week")
            setChart(chartType: "bar")
        case 1:
            getChartDataList(before: "2 weeks")
            setChart(chartType: "bar")
        case 2:
            getChartDataList(before: "3 months")
            setChart(chartType: "line")
        case 3:
            getChartDataList(before: "1 year")
            setChart(chartType: "line")
        default:
            break
        }
        
        combinedChartView.chartDescription?.text = "\(sender.titleForSegment(at: sender.selectedSegmentIndex)!)"
        combinedChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
    
    //⬇︎⬇︎-------------ChartView---------------⬇︎⬇︎
    func setChart(chartType: String) {
        combinedChartView.noDataText = "You need to provide data for the chart."
        
        //DataEntry -> DataEntries -> DataSet -> ChartData
        var barDataEntries: [BarChartDataEntry] = []
        var wLineDataEntries: [ChartDataEntry] = []
        var bLineDataEntries: [ChartDataEntry] = []
        
        for i in 0..<dateList.count {
            let barDataEntry = BarChartDataEntry(x: Double(i), yValues: [weightValueList[i]])
            let wLineDataEntry = ChartDataEntry(x: Double(i), y: weightValueList[i])
            let bLineDataEntry = ChartDataEntry(x: Double(i), y: bodyFatValueList[i])
            
            if !weightValueList[i].isZero{
                barDataEntries.append(barDataEntry)
                wLineDataEntries.append(wLineDataEntry)
            }
            if !bodyFatValueList[i].isZero{
                bLineDataEntries.append(bLineDataEntry)
            }
        }
        
        let barChartSet = BarChartDataSet(values: barDataEntries, label: "Weight: KG")
        let wLineChartSet = ScatterChartDataSet(values: wLineDataEntries, label: "Weight: KG")
        let bLineChartSet = LineChartDataSet(values: bLineDataEntries, label: "Body Fat: %")
        
        //customer setting
        bLineChartSet.colors = [NSUIColor.orange]
        bLineChartSet.circleHoleColor = NSUIColor.white
        bLineChartSet.circleColors = [NSUIColor.orange]

        let chartData = CombinedChartData()
        
        if chartType == "line" && dateList.count > 20{
            chartData.scatterData = ScatterChartData(dataSets: [wLineChartSet])
            wLineChartSet.scatterShapeSize = 6
            bLineChartSet.drawCirclesEnabled = false
            bLineChartSet.lineWidth = 5
        }
        else {
            chartData.barData = BarChartData(dataSets: [barChartSet])
            bLineChartSet.circleHoleRadius = 2
            bLineChartSet.circleRadius = 5
            bLineChartSet.lineWidth = 3
        }
        chartData.lineData = LineChartData(dataSets: [bLineChartSet])
        
        //set xAxis offset
        combinedChartView.xAxis.axisMinimum = -0.5;
        combinedChartView.xAxis.axisMaximum = Double(dateList.count) - 0.5;
        //set xAxis label
        combinedChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dateList)
        //set ChartView data
        combinedChartView.data = chartData
    }
    
    //⬇︎⬇︎----------GetChartDataList-----------⬇︎⬇︎
    func getChartDataList(before: String) {
        let realm = try! Realm()
        var predicate:NSPredicate!
        
        switch before {
        case "2 weeks":
            predicate = NSPredicate(format: "date > %@", Date().subtract(days: 14) as NSDate)
        case "1 months":
            predicate = NSPredicate(format: "date > %@", Date().subtract(days: 30) as NSDate)
        case "2 months":
            predicate = NSPredicate(format: "date > %@", Date().subtract(days: 60) as NSDate)
        case "3 months":
            predicate = NSPredicate(format: "date > %@", Date().subtract(days: 90) as NSDate)
        case "6 months":
            predicate = NSPredicate(format: "date > %@", Date().subtract(days: 180) as NSDate)
        case "1 year":
            predicate = NSPredicate(format: "date > %@", Date().subtract(days: 365) as NSDate)
        default:
            predicate = NSPredicate(format: "date > %@", Date().subtract(days: 7) as NSDate)
        }
        
        let dairyRecords = realm.objects(RLM_DairyRecord.self).filter(predicate)
        if dairyRecords.count > 0 {
            for (index, record) in dairyRecords.enumerated() {
                if index % 1 == 0 {
                    dateList.append(formatter.string(from: record.date as Date))
                    weightValueList.append(record.weight)
                    bodyFatValueList.append(record.bodyFat)
                }
            }
        }
    }
    
    //⬇︎⬇︎---------UITextFieldDelegate---------⬇︎⬇︎
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // User finished typing (hit return): hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            switch textField.tag {
            case 1:
                weightPicker.selectRow(weightData.num - 20, inComponent: 0, animated: true)
                weightPicker.selectRow(weightData.decimals, inComponent: 1, animated: true)
                weightTextField.text = String(mergeData(data: weightData)) + " kg"
                info.weight = mergeData(data: weightData)
                
            case 2:
                bodyfatPicker.selectRow(bodyFatData.num - 1, inComponent: 0, animated: true)
                bodyfatPicker.selectRow(bodyFatData.decimals, inComponent: 1, animated: true)
                bodyFatTextField.text = String(mergeData(data: bodyFatData)) + " %"
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
                weightData.num = weightPickerData[row]
            }
            else {
                weightData.decimals = decimalsPickerData[row]
            }
            weightTextField.text = String(mergeData(data: weightData)) + " kg"
            info.weight = mergeData(data: weightData)
            
        case 2:
            if component == 0 {
                bodyFatData.num = bodyFatPickerData[row]
            }
            else {
                bodyFatData.decimals = decimalsPickerData[row]
            }
            bodyFatTextField.text = String(mergeData(data: bodyFatData)) + " ％"
            info.bodyFat = mergeData(data: bodyFatData)
            
        default: break
        }
    }
    //pickerview width for component
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 66.0
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
            
            writeDairyRecord()
            
            self.performSegue(withIdentifier: "scaleBackToMainView", sender: self)
        }
    }
    
    @IBAction func pressSkipButton() {
        //self.performSegue(withIdentifier: "scaleBackToMainView", sender: self)
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
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
