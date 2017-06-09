//
//  WorkoutTableViewCell.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/6/9.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import UIKit

class WorkoutTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var itemTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var kmLabel: UILabel!
    @IBOutlet weak var setTableView: UITableView!
    
    var setStatus = 0
    var workoutSets:[WorkoutSet] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//⬇︎⬇︎--------WorkoutTableView----------⬇︎⬇︎
extension WorkoutTableViewCell: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "setCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SetTableViewCell
        let workoutSet = workoutSets[indexPath.row]
        cell.textLabel?.textAlignment = .center
        
        switch setStatus {
        case 1:
            cell.setLabel.text = "\(workoutSet.sets)sets " + "\(workoutSet.reps)reps " + "\(workoutSet.kg)kg"
        case 3:
            cell.setLabel.text = "\(workoutSet.sets)sets T:" +
                                    timeFormatter(mins: workoutSet.mins,
                                                  secs: workoutSet.secs)
        default:
            break
        }
        return cell
    }
    
    func timeFormatter(mins: Int, secs: Int) -> String {
        var minsStr:String = ""
        var secsStr:String = ""
        switch mins {
        case 0...9:
            minsStr = "00:0\(mins):"
        case 10...59:
            minsStr = "00:\(mins):"
        default:
            minsStr = "\((mins/60) < 10 ? "0\(mins/60)" : "\(mins/60)"):" +
            "\((mins%60) < 10 ? "0\(mins%60)" : "\(mins%60)"):"
        }
        switch secs {
        case 0...9:
            secsStr = "0\(secs)"
        default:
            secsStr = "\(secs)"
        }
        return minsStr + secsStr
    }
}
