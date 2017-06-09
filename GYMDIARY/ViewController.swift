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

struct DiaryWorkout {
    var category:Category
    var item:String
    var setStatus:Int
    var workoutSets:[WorkoutSet]
    
    init() {
        category = .Core
        item = ""
        setStatus = 1
        workoutSets = []
    }
    
    func showAll() {
        print("category:\(category)")
        print("item:\(item)")
        print("setStatus:\(setStatus)")
        for w in workoutSets {
            w.showAll()
        }
    }
}

class ViewController: UIViewController{
    
    @IBOutlet weak var workoutCalendarView: JTAppleCalendarView!
    @IBOutlet weak var workoutTable: UITableView!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var year: UILabel!
    
    var info = TrainerInfo()
    var myUserDefaults = UserDefaults()
    
    let formatter = DateFormatter()
    
    var selectedDay = Date()
    var workoutDay:[Date] = []
    var diaryWorkouts:[DiaryWorkout] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getWorkoutDateList()
        
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
        
        //⬇︎⬇︎---------WorkoutTable------------⬇︎⬇︎
        workoutTable.allowsSelection = false
        
        //⬇︎⬇︎--------WorkoutCalendar----------⬇︎⬇︎
        workoutCalendarView.minimumLineSpacing = 0
        workoutCalendarView.minimumInteritemSpacing = 0
        
        backToToday()
        
        workoutCalendarView.visibleDates { visibleDates in
            self.setupCalendarTitle(visibleDates: visibleDates)
        }
        
    }
    
    func setupCalendarTitle(visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first?.date
        formatter.dateFormat = "YYYY"
        year.text = formatter.string(from: date!) + " "
        formatter.dateFormat = "MMMM"
        month.text = formatter.string(from: date!)
    }
    
    func getWorkoutDateList() {
        let realm = try! Realm()
        
        let workoutSets = realm.objects(RLM_WorkoutSet.self)//.filter("date BETWEEN %@", [startDate, endDate])
        if workoutSets.count > 0 {
            for workoutSet in workoutSets {
                workoutDay.append(workoutSet.date as Date)
            }
        }
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
    
    func handleCellIsWorkoutDay(cell: JTAppleCell?, date: Date) {
        guard let vaildCell = cell as? WorkoutCalendarCell  else {
            return
        }

        if workoutDay.contains(date) {
            vaildCell.workoutView.isHidden = false
            vaildCell.workoutView.layer.borderColor = UIColor.white.cgColor
        }
        else {
            vaildCell.workoutView.isHidden = true
        }
    }
    
    //⬇︎⬇︎--------Prepare segue----------⬇︎⬇︎
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddWorkout" {
            if let destinationController = segue.destination as? AddWorkoutViewController {
                destinationController.selectedDay = self.selectedDay
            }
        }
    }
    
    //⬇︎⬇︎--------Unwind to Root View Controller----------⬇︎⬇︎
    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
        if segue.identifier == "addWorkoutBackTo" {
            workoutDay.removeAll()
            getWorkoutDateList()
            workoutCalendarView.reloadData()
            workoutCalendarView.selectDates(from: selectedDay, to: selectedDay, triggerSelectionDelegate: true, keepSelectionIfMultiSelectionAllowed: false)
        }
    }
    
    @IBAction func backToToday() {
        workoutCalendarView.scrollToDate(Date())
        workoutCalendarView.selectDates(from: Date(), to: Date(), triggerSelectionDelegate: true, keepSelectionIfMultiSelectionAllowed: false)
        selectedDay = Date()
        workoutTable.reloadData()
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
        handleCellIsWorkoutDay(cell: cell, date: date)
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellIsToday(cell: cell, date: date)
        handleCellIsWorkoutDay(cell: cell, date: date)
        
        if cellState.dateBelongsTo != .thisMonth {
            workoutCalendarView.scrollToDate(date)
        }
        
        // reload workoutTable
        selectedDay = date
        getWorkoutSetsList(selectDay: selectedDay)
        workoutTable.reloadData()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellIsToday(cell: cell, date: date)
        handleCellIsWorkoutDay(cell: cell, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        setupCalendarTitle(visibleDates: visibleDates)
    }
    
    func getWorkoutSetsList(selectDay: Date) {
        if !diaryWorkouts.isEmpty {
            diaryWorkouts.removeAll()
        }
        
        let realm = try! Realm()
        let workoutSets = realm.objects(RLM_WorkoutSet.self).filter("date = %@", selectedDay)
        if workoutSets.count > 0 {
            for ws in workoutSets {
                if diaryWorkouts.count != 0 {
                    var flag = true
                    if ws.item != "Running" && ws.item != "Swimming" {
                        for (i, dw) in diaryWorkouts.enumerated() {
                            if dw.item == ws.item {
                                flag = false
                                var dws = WorkoutSet()
                                dws.sets = ws.sets
                                dws.reps = ws.reps
                                dws.mins = ws.mins
                                dws.secs = ws.secs
                                dws.kg = ws.kg
                                dws.km = ws.km
                                diaryWorkouts[i].workoutSets.append(dws)
                                break
                            }
                        }
                    }

                    if flag { //flag = true no contain
                        var dw = DiaryWorkout()
                        dw.category = Category(rawValue: ws.category)!
                        dw.item = ws.item
                        dw.setStatus = ws.setStatus
                        var dws = WorkoutSet()
                        dws.sets = ws.sets
                        dws.reps = ws.reps
                        dws.mins = ws.mins
                        dws.secs = ws.secs
                        dws.kg = ws.kg
                        dws.km = ws.km
                        dw.workoutSets.append(dws)
                        diaryWorkouts.append(dw)
                    }
                }
                else {
                    var dw = DiaryWorkout()
                    dw.category = Category(rawValue: ws.category)!
                    dw.item = ws.item
                    dw.setStatus = ws.setStatus
                    var dws = WorkoutSet()
                    dws.sets = ws.sets
                    dws.reps = ws.reps
                    dws.mins = ws.mins
                    dws.secs = ws.secs
                    dws.kg = ws.kg
                    dws.km = ws.km
                    dw.workoutSets.append(dws)
                    diaryWorkouts.append(dw)
                }
            }
        }
    }
}

//⬇︎⬇︎--------WorkoutTableView----------⬇︎⬇︎
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaryWorkouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "workoutCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WorkoutTableViewCell
        let diaryWorkout = diaryWorkouts[indexPath.row]
        
        cell.categoryLabel.text = "\(diaryWorkout.category):"
        cell.itemTextView.text = "\(diaryWorkout.item)"
        cell.itemTextView.isScrollEnabled = false
        cell.setTableView.allowsSelection = false
        
        switch diaryWorkout.setStatus {
        case 2:
            cell.kmLabel.isHidden = false
            cell.timeLabel.isHidden = false
            cell.rateLabel.isHidden = false
            cell.setTableView.isHidden = true
            cell.kmLabel.text = "\(diaryWorkout.workoutSets[0].km)Km"
            cell.timeLabel.text = timeFormatter(mins: diaryWorkout.workoutSets[0].mins,
                                                secs: diaryWorkout.workoutSets[0].secs)
            cell.rateLabel.text = timeRate(km: diaryWorkout.workoutSets[0].km,
                                           mins: diaryWorkout.workoutSets[0].mins,
                                           secs: diaryWorkout.workoutSets[0].secs)
        default://1,3
            cell.kmLabel.isHidden = true
            cell.timeLabel.isHidden = true
            cell.rateLabel.isHidden = true
            cell.setTableView.isHidden = false
            cell.workoutSets.removeAll()
            cell.workoutSets = diaryWorkout.workoutSets
            cell.setStatus = diaryWorkout.setStatus
            cell.setTableView.reloadData()
            break
        }
        
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
