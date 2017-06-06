//
//  ViewController.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/5/2.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import UIKit
import RealmSwift
import JTAppleCalendar

class ViewController: UIViewController{
    
    @IBOutlet weak var workoutCalendarView: JTAppleCalendarView!
    @IBOutlet weak var workoutTable: UITableView!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var year: UILabel!
    
    var selectedDay = Date()
    
    var info = TrainerInfo()
    var myUserDefaults = UserDefaults()
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //get info
        if let data = UserDefaults.standard.data(forKey: "info"),
            let trainerInfo = NSKeyedUnarchiver.unarchiveObject(with: data) as? TrainerInfo {
            info = trainerInfo
        } else {
            print("show new trainer info view")
        }
        
        formatter.dateFormat = "YYYY-MM-dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let today = formatter.string(from: info.today)
        
        DispatchQueue.main.async {
            if self.info.name == "" {
                self.performSegue(withIdentifier: "goToTrainerInfo", sender: self)
            }
            else if today != self.formatter.string(from: Date()) {
                self.performSegue(withIdentifier: "goToWeightRecord", sender: self)
            }
        }
        
        //⬇︎⬇︎--------WorkoutCalendar----------⬇︎⬇︎
        workoutCalendarView.minimumLineSpacing = 0
        workoutCalendarView.minimumInteritemSpacing = 0
        
        backToToday()
        
        workoutCalendarView.visibleDates { visibleDates in
            self.setupCalendarTitle(visibleDates: visibleDates)
        }
        
    }

    @IBAction func resetTrainerInfo() {
        myUserDefaults.removeObject(forKey: "info")
        myUserDefaults.synchronize()
        print("reset")

        let realm = try! Realm()
        let predicate = NSPredicate(format: "date > %@", Date() as NSDate)
        if let dairyRecords = realm.objects(RLM_DairyRecord.self).filter(predicate).first {
            try! realm.write {
                realm.delete(dairyRecords)
            }
        }

    }
    
    @IBAction func backToToday() {
        workoutCalendarView.scrollToDate(Date())
        workoutCalendarView.selectDates(from: Date(), to: Date(), triggerSelectionDelegate: true, keepSelectionIfMultiSelectionAllowed: false)
        selectedDay = Date()
        workoutTable.reloadData()
    }
    
    func setupCalendarTitle(visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first?.date
        formatter.dateFormat = "YYYY"
        year.text = formatter.string(from: date!) + " "
        formatter.dateFormat = "MMMM"
        month.text = formatter.string(from: date!)
    }
    
    func handleCellTextColor(cell: JTAppleCell?, cellState: CellState) {
        guard let vaildCell = cell as? WorkoutCalendarCell  else {
            return
        }
        
        if cellState.isSelected {
            vaildCell.dateCell.textColor = UIColor.black
        }
        else {
            if cellState.dateBelongsTo == .thisMonth {
                if cellState.day == .saturday {
                    vaildCell.dateCell.textColor = UIColor.yellow
                }
                else if cellState.day == .sunday {
                    vaildCell.dateCell.textColor = UIColor.cyan
                }
                else {
                    vaildCell.dateCell.textColor = UIColor.white
                }
            }
            else
            {
                vaildCell.dateCell.textColor = UIColor.darkGray
            }
        }
    }
    
    func handleCellSelected(cell: JTAppleCell?, cellState: CellState) {
        guard let vaildCell = cell as? WorkoutCalendarCell  else {
            return
        }
        if cellState.isSelected {
            vaildCell.selectView.isHidden = false
        }
        else {
            vaildCell.selectView.isHidden = true
        }
    }
    
    func handleCellIsToday(cell: JTAppleCell?, date: Date) {
        guard let vaildCell = cell as? WorkoutCalendarCell  else {
            return
        }
        
        formatter.dateFormat = "YYYY-MM-dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        if formatter.string(from: date) == formatter.string(from: Date()) {
            vaildCell.todayView.isHidden = false
            vaildCell.dateCell.textColor = UIColor.red
        }
        else {
            vaildCell.todayView.isHidden = true
        }
    }

    //⬇︎⬇︎--------Unwind to Root View Controller----------⬇︎⬇︎
    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
        print("Unwind to Root View Controller")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//⬇︎⬇︎--------WorkoutCalendar----------⬇︎⬇︎
extension ViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "YYYY-MM-dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = Date().subtract(years: 5)
        let endDate = Date().add(years: 5)
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6,
                                                 calendar: Calendar.current,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfGrid,
                                                 firstDayOfWeek: .sunday)
        return parameters
    }
    
}

extension ViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "workoutCalendarCell", for: indexPath) as! WorkoutCalendarCell
        cell.dateCell.text = cellState.text
        
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellIsToday(cell: cell, date: date)

        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellIsToday(cell: cell, date: date)
        
        if cellState.dateBelongsTo != .thisMonth {
            workoutCalendarView.scrollToDate(date)
        }
        
        // reload workoutTable
        selectedDay = date
        workoutTable.reloadData()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellIsToday(cell: cell, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        setupCalendarTitle(visibleDates: visibleDates)
    }
}

//⬇︎⬇︎--------WorkoutTableView----------⬇︎⬇︎
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "workoutCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        formatter.dateFormat = "YYYY-MM-dd"
        
        cell.textLabel?.text = formatter.string(from: selectedDay)
        
        return cell
    }
}


//close keyboard by touching anywhere
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func mergeData(data : (num:Int, decimals:Int)) -> Double {
        return Double("\(data.num)" + "." + "\(data.decimals)")!
    }
}

extension Date {
    
    /// Returns a Date with the specified days added to the one it is called with
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
        var targetDay: Date
        targetDay = Calendar.current.date(byAdding: .year, value: years, to: self)!
        targetDay = Calendar.current.date(byAdding: .month, value: months, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .day, value: days, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .hour, value: hours, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .minute, value: minutes, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .second, value: seconds, to: targetDay)!
        return targetDay
    }
    
    /// Returns a Date with the specified days subtracted from the one it is called with
    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
        let inverseYears = -1 * years
        let inverseMonths = -1 * months
        let inverseDays = -1 * days
        let inverseHours = -1 * hours
        let inverseMinutes = -1 * minutes
        let inverseSeconds = -1 * seconds
        return add(years: inverseYears, months: inverseMonths, days: inverseDays, hours: inverseHours, minutes: inverseMinutes, seconds: inverseSeconds)
    }
    
}
