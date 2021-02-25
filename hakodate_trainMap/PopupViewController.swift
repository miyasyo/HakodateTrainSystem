//
//  PopupViewController.swift
//  hakodate_trainMap
//
//  Created by 宮下翔伍 on 2020/10/18.
//  Copyright © 2020 宮下翔伍. All rights reserved.
//

import Foundation
import UIKit

class PopupViewController: UIViewController {
    
    @IBOutlet weak var decisionButton: UIButton!
    
    @IBOutlet weak var timeTextField: UITextField!
    
    @IBAction func selectTime(_ sender: Any) {
        if(timeTextField.text?.isAlphanumeric() == true){
        self.performSegue(withIdentifier: "toRouteView", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeTextField.text = "30"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRouteView" {
            let nV = segue.destination as! routeViewController
            if(editmode != "add") {
                endPoint = tapSpot
            }
            nV.trainId = timeTableId
            nV.startTrainId = startTrain
            nV.durationSpotTime = Int(timeTextField.text!) ?? 0
        }
    }
}

extension String {
    // 半角数字の判定
    func isAlphanumeric() -> Bool {
        return self.range(of: "[^0-9]+", options: .regularExpression) == nil && self != ""
    }
}
