//
//  TimeTableView.swift
//  hakodate_trainMap
//
//  Created by 宮下翔伍 on 2020/07/18.
//  Copyright © 2020 宮下翔伍. All rights reserved.
//

import Foundation
import UIKit

class TimeTableView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.addTarget(self, action: #selector(closeView), for: .touchDown)
        }
    }
    
    @IBOutlet weak var timeTableView: UITableView! {
        didSet {
            timeTableView.delegate = self
            timeTableView.dataSource = self
        }
    }
    
    @objc func closeView() {
        timeTableList.removeAll()
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeTableList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "timeTableCell", for: indexPath)
        tableCell.textLabel?.text = timeTableList[indexPath.row]
        return tableCell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
