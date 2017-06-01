//
//  WeatherTableVIewCell.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/6/1.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import UIKit

class WeatherTableVIewCell: UITableViewCell {

    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var conditionImage: UIImageView!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
