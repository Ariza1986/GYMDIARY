//
//  AddWorkoutViewController.swift
//  GYMDIARY
//
//  Created by ArizaKuo on 2017/6/5.
//  Copyright © 2017年 ArizaKuo. All rights reserved.
//

import UIKit

class AddWorkoutViewController: UIViewController {
   
    @IBOutlet weak var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        
        //⬇︎⬇︎--------ViewSetting----------⬇︎⬇︎
        //close keyboard by touching anywhere
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
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
    
    func accept() {
        print("accept")
    }

}
