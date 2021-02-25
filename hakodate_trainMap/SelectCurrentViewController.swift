//
//  SelectCurrentViewController.swift
//  hakodate_trainMap
//
//  Created by 宮下翔伍 on 2020/11/09.
//  Copyright © 2020 宮下翔伍. All rights reserved.
//

import Foundation
import UIKit
var nightMinite = 0
var nightHour = 0

class SelectCurrentViewController: UIViewController {
    
    var currentPoint = ""
    var currentLatitude = ""
    var currentLongitude = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func selectCurrent1(_ sender: Any) {
        currentLatitude = "41.791168"
        currentLongitude = "140.7494443"
        self.performSegue(withIdentifier: "SelectToMap", sender: nil)
    }
    
    @IBAction func selectCurrent2(_ sender: Any) {
        currentLatitude = "41.7748597"
        currentLongitude = "140.7251458"
        self.performSegue(withIdentifier: "SelectToMap", sender: nil)
    }
    
    @IBAction func selectCurrent3(_ sender: Any) {
        currentLatitude = "41.777988"
        currentLongitude = "140.8052943"
        self.performSegue(withIdentifier: "SelectToMap", sender: nil)
    }
    
    @IBAction func timeSwitch(_ sender: UISwitch) {
        if sender.isOn {
           print("onです")
            nightHour = 10
            nightMinite = 30
        }else{
            nightHour = 0
            nightMinite = 0
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectToMap" {
            let nV = segue.destination as! ViewController
            current_lati = currentLatitude
            current_lon = currentLongitude
        }
    }
    
    
}
