//
//  ScheduleViewController.swift
//  hakodate_trainMap
//
//  Created by 宮下翔伍 on 2020/06/17.
//  Copyright © 2020 宮下翔伍. All rights reserved.
//

import Foundation
import UIKit

var celllist: [String] = []
class ScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var mapButton: UIButton! {
        didSet {
            mapButton.addTarget(self, action: #selector(goMap), for: .touchDown)
        }
    }
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton! {
        didSet {
            deleteButton.addTarget(self, action: #selector(deleteSchedule), for: .touchDown)
        }
    }
    
    var durication: [String] = []
    var spottoTime: [String] = []
    var startSpot: String = ""
    var endSpot: String = ""
    var indexcount = 0
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionList[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 60
    }
    
    // Section数
       func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList.count
       }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
           return "スポット\(section + 1)"
       }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath)
        if(indexPath.section == 0) {
        cell.textLabel?.text = celllist[indexPath.row]
        }
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = celllist[indexPath.row]
        case 1:
            cell.textLabel?.text = celllist[sectionList[0] + indexPath.row]
        case 2:
            cell.textLabel?.text = celllist[sectionList[0] + sectionList[1] + indexPath.row]
        default:
            cell.textLabel?.text = celllist[sectionList[0] + sectionList[1] + sectionList[2] + indexPath.row]
        }
            
            
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
            // switch文でsectionごとに色を変更する
            switch section {
            case 0:
                view.tintColor = .blue
                var header = view as! UITableViewHeaderFooterView
                header.textLabel?.textColor = .white

            case 1:
                view.tintColor = .orange
                var header = view as! UITableViewHeaderFooterView
                header.textLabel?.textColor = .white
            
            case 2:
                view.tintColor = .green
                let header = view as! UITableViewHeaderFooterView
                header.textLabel?.textColor = .white

            default:
                view.tintColor = .red
                let header = view as! UITableViewHeaderFooterView
                header.textLabel?.textColor = .white
            }
    }
    
    @objc func deleteSchedule() {
        let alert: UIAlertController = UIAlertController(title: "警告", message: "本当にスケジュールを削除してもよろしいですか？", preferredStyle:  UIAlertController.Style.alert)
        
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            celllist.removeAll()
            waypointList.removeAll()
            waypointKeyList.removeAll()
            startPositionList.removeAll()
            endPositionList.removeAll()
            makeSignal = false
            editmode = "go"
            spot_type = [""]
            spot_id = [0]
            spot_title = [""]
            spot_lat = [0]
            spot_lon = [0]
            start_goal_idList.removeAll()
            station_lon_list.removeAll()
            station_lat_list.removeAll()
            stationNameList.removeAll()
            self.performSegue(withIdentifier: "fromScheduletoMapView", sender: nil)
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
        })
        
        // ③ UIAlertControllerにActionを追加
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        // ④ Alertを表示
        present(alert, animated: true, completion: nil)
    }
    
    @objc func goMap() {
        self.performSegue(withIdentifier: "fromScheduletoMapView", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(celllist)
        myTableView.delegate = self
        myTableView.dataSource = self
        print(sectionList)
    }
}
