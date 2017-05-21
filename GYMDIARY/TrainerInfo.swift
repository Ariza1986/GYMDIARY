//
//  TrainerInfo.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/5/21.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import Foundation

enum Sex {
    case Male
    case Female
}

struct DairyData {
    var date = ""
    var data = 0.0
}

class TrainerInfo {
    var name:String = ""
    var sex:Sex = .Male
    var birthDay:String = ""
    var height:Double = 0.0
    var weight:[DairyData] = []
    var bodyFat:[DairyData] = []
    
    func showAll() {
        print("name:\t" + "\(name)" + "\n" +
            "sex:\t\t" + "\(sex)" + "\n" +
            "birthDay:\t" + "\(birthDay)" + "\n" +
            "height:\t" + "\(height)" + "\n" +
            "weight:\t" + "\(weight)" + "\n" +
            "bodyFat:\t" + "\(bodyFat)")
    }
}
