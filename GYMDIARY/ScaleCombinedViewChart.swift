//
//  scaleCombinedViewChart.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/5/26.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class ScaleCombinedViewChart: CombinedChartView {
    
    //for ChartView
    var dateList: [String]! = []
    var weightValueList: [Double]! = []
    var bodyFatValueList: [Double]! = []
    
    //catch date YYYYMMdd
    let today = Date()
    let formatter = DateFormatter()
    
     convenience init() {
     
        self.init()
        
        //⬇︎⬇︎--------DefaultValue---------⬇︎⬇︎
        //catch date YYYYMMdd
        formatter.dateFormat = "MM/dd"
        
        //⬇︎⬇︎----------ChartView----------⬇︎⬇︎
        self.backgroundColor = UIColor.white
        self.xAxis.labelPosition = .bottom
        self.chartDescription?.text = "week"
        self.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        getChartDataList(before: "week")
        setChart(chartType: "bar")
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
        
        self.chartDescription?.text = "\(sender.titleForSegment(at: sender.selectedSegmentIndex)!)"
    }
    
    //⬇︎⬇︎-------------ChartView---------------⬇︎⬇︎
    func setChart(chartType: String) {
        self.noDataText = "You need to provide data for the chart."
        
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
        
        chartData.lineData = LineChartData(dataSets: [bLineChartSet])
        
        if chartType == "line" && dateList.count > 20{
            chartData.scatterData = ScatterChartData(dataSets: [wLineChartSet])
            wLineChartSet.scatterShapeSize = 6
            bLineChartSet.drawCirclesEnabled = false
            bLineChartSet.lineWidth = 5
            self.animate(xAxisDuration: 1.0)
        }
        else {
            chartData.barData = BarChartData(dataSets: [barChartSet])
            bLineChartSet.circleHoleRadius = 2
            bLineChartSet.circleRadius = 5
            bLineChartSet.lineWidth = 3
            self.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        }
        
        //set xAxis offset
        self.xAxis.axisMinimum = -0.5;
        self.xAxis.axisMaximum = Double(dateList.count) - 0.5;
        //set xAxis label
        self.xAxis.valueFormatter = IndexAxisValueFormatter(values:dateList)
        //set ChartView data
        self.data = chartData
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
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

