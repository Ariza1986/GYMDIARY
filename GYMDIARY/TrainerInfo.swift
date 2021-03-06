//
//  TrainerInfo.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/5/21.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import Foundation
import RealmSwift

class RLM_DairyRecord:Object {
    private(set) dynamic var uuid:String = UUID().uuidString
    dynamic var date:NSDate = NSDate()
    dynamic var weight:Double = 0.0
    dynamic var bodyFat:Double = 0.0
    
    override static func primaryKey() -> String {
        return "uuid"
    }
}

class RLM_WorkoutSet:Object {
    
    private(set) dynamic var uuid:String = UUID().uuidString
    dynamic var date:NSDate = NSDate()
    dynamic var category:Int = 0
    dynamic var item:String = ""
    dynamic var setStatus:Int = 1
    
    dynamic var sets:Int = 0
    dynamic var reps:Int = 0
    dynamic var mins:Int = 0
    dynamic var secs:Int = 0
    dynamic var kg:Double = 0.0
    dynamic var km:Double = 0.0
    
    override static func primaryKey() -> String {
        return "uuid"
    }
}

class TrainerInfo: NSObject, NSCoding {
    var name:String
    var sex:String
    var birthDay:String
    var height:Double
    var weight:Double
    var bodyFat:Double
    var today:Date
    
    override init() {
        name = ""
        sex = "♂"
        birthDay = ""
        height = 0.0
        weight = 0.0
        bodyFat = 0.0
        today = Date()
    }
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as? String ?? ""
        self.sex = decoder.decodeObject(forKey: "sex") as? String ?? "♂"
        self.birthDay = decoder.decodeObject(forKey: "birthDay") as? String ?? ""
        self.height = decoder.decodeDouble(forKey: "height")
        self.weight = decoder.decodeDouble(forKey: "weight")
        self.bodyFat = decoder.decodeDouble(forKey: "bodyFat")
        self.today = decoder.decodeObject(forKey: "today") as? Date ?? Date()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(sex, forKey: "sex")
        coder.encode(birthDay, forKey: "birthDay")
        coder.encode(height, forKey: "height")
        coder.encode(weight, forKey: "weight")
        coder.encode(bodyFat, forKey: "bodyFat")
        coder.encode(today, forKey: "today")
    }
    
    func showAll() {
        print("name:\t\t" + "\(name)" + "\n" +
            "sex:\t\t\t" + "\(sex)" + "\n" +
            "birthDay:\t" + "\(birthDay)" + "\n" +
            "height:\t\t" + "\(height)" + "\n" +
            "weight:\t\t" + "\(weight)" + "\n" +
            "bodyFat:\t\t" + "\(bodyFat)" + "\n" +
            "today:\t\t" + "\(today)")
    }
}
