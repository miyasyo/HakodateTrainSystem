//
//  routeViewController.swift
//  hakodate_trainMap
//
//  Created by 宮下翔伍 on 2020/06/10.
//  Copyright © 2020 宮下翔伍. All rights reserved.
//

import Foundation
import UIKit
import MapKit

var startPositionList:[CLLocationCoordinate2D] = []
var endPositionList:[CLLocationCoordinate2D] = []
var makeSignal = false
var waypointList: [String] = []
var waypointKeyList: [String] = [] //リクエストで使用する最寄り駅の座標リスト
var waypointTypeList: [String] = []
var useTrainTimeList: [Int] = []
var endPoint = ""
var startPoint = ""
var endSpotKey = "" //目的地の座標
var spotTimeList: [Int] = []
var start_mid_id = 0
var sortgoalspotList: [String] = []
var sortgoalspotKeyList: [String] = []
var sortwaypointList: [String] = [] //sort後のwaypointList
var sortwaypointKeyList: [String] = [] //sort後のwaypointKeyList
var sectionList: [Int] = []
var stepList: [Int] = []

class routeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var durication: [String] = []
    private var spottoTime: [String] = []
    var trainDurationList = [String]()
    var startTrainId = 0
    var trainId = 0
    var currentTime = ""
    var timeDataList = [String]()
    var timeDataList_re = [String]()
    var useTrainTime = 0
    var stationTime = ""
    var durationSpotTime = 0
    var currentHour: Int = 0
    var currentMinute: Int = 0
    var stationHour: Int = 0
    var stationMinute: Int = 0
    var timeTableCount = 0
    
    @IBOutlet weak var starField: UITextField!
    @IBOutlet weak var endField: UITextField!
    @IBOutlet weak var addWaypointButton: UIButton!
    
    
    @IBAction func closeView(_ sender: Any) {
        editmode = "go"
        waypointList.removeAll()
        goalspot_list.removeAll()
        start_goal_idList.removeAll()
        stationNameList.removeAll()
        station_lat_list.removeAll()
        station_lon_list.removeAll()
        endPoint = ""
        self.performSegue(withIdentifier: "toMapView", sender: nil)
    }
    
    @IBAction func waypointAdd(_ sender: Any) {
        editmode = "add"
        start_mid_id = trainId
        self.performSegue(withIdentifier: "toMapView", sender: nil)
    }
    
    @IBAction func routeSearch(_ sender: Any) {
        let startSpot = starField.text
        var url = ""
        if(waypointList.count > 2) {
            change_spot_number()
        }else{
            sortwaypointList = waypointList
            sortwaypointKeyList = waypointKeyList
            result_durication_trum(start: sortwaypointList[0], end: sortwaypointList[1])
        }
        var stepcount = 0
        if(sortwaypointKeyList.count != 0) {
            var waypointText = sortwaypointKeyList[0]
            for i in 1..<sortwaypointKeyList.count {
                waypointText += " | " + sortwaypointKeyList[i]
            }
            url = "https://maps.googleapis.com/maps/api/directions/json?language=ja&origin=" + startSpot! + "&destination=" + endSpotKey
                + "&waypoints=" + "\(waypointText)" + "&mode=walking&key=AIzaSyCYQWY6YRPPLDMNSBONTfz0Xshu7ey4I6Q"
        }else {
            url = "https://maps.googleapis.com/maps/api/directions/json?language=ja&origin=" + startSpot! + "&destination=" + endSpotKey
                + "&mode=walking&key=AIzaSyCYQWY6YRPPLDMNSBONTfz0Xshu7ey4I6Q"
        }
        // print(url)
        let encodeUrlString: String = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let testurl: URL = URL(string:encodeUrlString)!
        let task: URLSessionTask = URLSession.shared.dataTask(with: testurl, completionHandler: {(data, response, error) in
            do{
                let user = try! JSONDecoder().decode(directionAPI.self, from: data!)
                let routes = user.routes
                for route in routes {
                    let legs = route.legs
                    for leg in legs {
                        let steps = leg.steps
                        for step in steps {
                            let start = step.start_location
                            let end = step.end_location
                            let startposition = CLLocationCoordinate2D(latitude: start.lat, longitude: start.lng)
                            let endposition = CLLocationCoordinate2D(latitude: end.lat, longitude: end.lng)
                            startPositionList.append(startposition)
                            endPositionList.append(endposition)
                            print("テスト:\(startPositionList.count)")
                        }
                        self.durication.append(leg.distance.text)
                        self.spottoTime.append(leg.duration.text)
                        stepcount += 1
                        
                        if(stepcount % 3 == 0) {
                            if(stepList.count == 0) {
                            stepList.append(startPositionList.count)
                            }else{
                                var sum = 0
                                for i in 0..<stepList.count {
                                sum += stepList[i]
                                }
                                stepList.append(startPositionList.count - sum)
                            }
                        }
                        print("step=\(stepList)")
                    }
                }
                DispatchQueue.main.async {
                    self.result_stationTime()
                    print("step数=\(startPositionList.count)")
                    self.performSegue(withIdentifier: "toScheduleView", sender: self)
                }
            }
            catch {
                let alert: UIAlertController = UIAlertController(title: "エラーが発生しました。", message: "\(error)", preferredStyle:  UIAlertController.Style.alert)
                
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                    // ボタンが押された時の処理を書く（クロージャ実装）
                    (action: UIAlertAction!) -> Void in
                    return
                })
                // ③ UIAlertControllerにActionを追加
                alert.addAction(defaultAction)
                
                // ④ Alertを表示
                self.present(alert, animated: true, completion: nil)
            }
        })
        task.resume()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waypointList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "waypointCell", for: indexPath)
        tableCell.textLabel?.text = waypointList[indexPath.row]
        return tableCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toScheduleView" {
            let nv = segue.destination as! ScheduleViewController
            var traincount = 0
            var switch_station = "ride"
            var sectioncount = 0
            nv.spottoTime = self.spottoTime
            celllist.append("時刻: \(currentTime) \n現在地：　\(self.starField.text!)") //現在地と現在時刻
            celllist.append("移動時間：\(spottoTime[0]) 距離：\(self.durication[0])") //目的地または経由地最寄りの電停までの移動時間、距離
            result_stationTime()
            
            if(editmode != "add") { //スポットが一つのみの処理
                celllist.append("時刻: \(stationTime) \n乗車駅: \(sortwaypointList[0])")
                celllist.append("移動時間：\(useTrainTimeList[0])分 距離：\(self.durication[1])")
                stationTime = add_time(currentHour: stationHour, currentMinute: stationMinute, addMinute: useTrainTimeList[0])
                celllist.append("時刻: \(stationTime) \n降車駅: \(sortwaypointList[1])")
                celllist.append("移動時間：\(spottoTime[2]) 距離：\(self.durication[2])")
                let golltoTime = spottoTime[2].dropLast()
                stationTime = add_time(currentHour: stationHour, currentMinute: stationMinute, addMinute: Int(golltoTime)!) //目的地到着時刻
            } else { // 複数スポットの処理
                var spotTimeListCount = 0
                if(waypointList.count != 0) {
                    for i in 0..<sortwaypointList.count {
                        if(waypointTypeList[i] == "t") {
                            if(switch_station == "ride") {
                                celllist.append("時刻: \(stationTime) \n乗車駅: \(sortwaypointList[i])")
                                switch_station = "down"
                            }else{
                                celllist.append("時刻: \(stationTime) \n降車駅: \(sortwaypointList[i])")
                                switch_station = "ride"
                            }
                            if(i < self.spottoTime.count-1) {
                                // print("durication\(self.durication)")
                                // print("spotToTime\(self.spottoTime)")
                                
                                if(i % 3 == 0) {
                                    celllist.append("移動時間(市電)：\(useTrainTimeList[traincount])分 距離：\(self.durication[i+1])")
                                    stationTime = add_time(currentHour: stationHour, currentMinute: stationMinute, addMinute: useTrainTimeList[traincount])
                                    traincount += 1
                                } else {
                                    celllist.append("移動時間(徒歩)：\(spottoTime[i+1]) 距離：\(self.durication[i+1])")
                                    let stationToSpotTime = spottoTime[i+1].dropLast()
                                    stationTime = add_time(currentHour: stationHour, currentMinute: stationMinute, addMinute: Int(stationToSpotTime)!) //経由地到着時刻
                                }
                            }
                        } else {
                            celllist.append("時刻: \(stationTime) \n経由スポット\(spotTimeListCount+1): \(sortwaypointList[i])")
                            celllist.append("滞在時間:\(spotTimeList[spotTimeListCount])分")
                            if(sectionList.count == 0) {
                            sectionList.append(celllist.count)
                                sectioncount = celllist.count
                            }else{
                                sectionList.append(celllist.count - sectioncount)
                                sectioncount += sectionList[sectionList.count-1]
                            }
                            celllist.append("移動時間：\(spottoTime[i]) 距離：\(self.durication[i])")
                            let stationToSpotTime = spottoTime[i].dropLast()
                            stationTime = add_time(currentHour: stationHour, currentMinute: stationMinute, addMinute: spotTimeList[spotTimeListCount] + Int(stationToSpotTime)!) //滞在時間考慮
                            currentTime = stationTime
                            result_stationTime()
                            spotTimeListCount += 1
                        }
                    }
                }
            }
            celllist.append("時刻: \(stationTime) \n目的地：　\(self.endField.text!)")
            sectionList.append(celllist.count - sectioncount)
            makeSignal = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // print("テスト\(stationNameData.firstIndex(of: "昭和橋駅"))")
        // print("テスト\(stationNameData)")
        print(stationNameList)
        print("start_goal_id=\(start_goal_idList)")
        print("目的地:\(goalspot_list)")
        print("stationNameData=\(stationNameList)")
        // print("目的地座標lat；\(goalspot_lat_list)")
        //  print("目的地座標lon；\(goalspot_lon_list)")
        //  print(waypointTypeList)
        //  print(spot_lat)
        //  result_durication_trum(start: "", end: "")
        spotTimeList.append(durationSpotTime)
        //  print(startTrainId)
        let dt = Date()
        currentHour = Calendar.current.component(.hour, from: Date())
        currentMinute = Calendar.current.component(.minute, from: Date())
        
        if(nightHour != 0) {
            currentHour = nightHour
            currentMinute = nightMinite
        }
        if(currentMinute < 10){
            currentTime = "\(currentHour):0\(currentMinute):00"
        }else{
            currentTime = "\(currentHour):\(currentMinute):00"
        }
        currentTime = "10:30:00"
        //print(currentTime)
        endField.text = endPoint
        starField.text = startPoint
        // print(stationName)
        waypointTypeList.append("t")
        waypointTypeList.append("t")
        waypointList.append(stationName)
        waypointKeyList.append("\(station_lat),\(station_lon)")
        last_went_station = stationName
        last_went_station_key = "\(station_lat),\(station_lon)"
        print("typpe:\(waypointTypeList)")
        print("waypointName:\(waypointList)")
    }
    
    func add_time(currentHour: Int, currentMinute: Int, addMinute: Int)-> String { //時間計算ツール
        var minute = currentMinute
        var hour = currentHour
        for i in 0..<addMinute {
            if(minute < 59) {
                minute += 1
            } else {
                hour += 1
                minute = 0
            }
        }
        
        stationHour = hour
        stationMinute = minute
        if(minute < 10){
            return "\(hour):0\(minute):00"
        }else{
            return "\(hour):\(minute):00"
        }
    }
    
    func result_durication_trum(start: String, end: String) {
        
        var count = 0
        
        guard let path2 = Bundle.main.path(forResource:"durationTime", ofType:"csv") else {
            return
        }
        do {
            
            trainId = stationNameData.firstIndex(of: end)! + 1
            startTrainId = stationNameData.firstIndex(of: start)! + 1
            //時刻表のデータ
            print("trainId = \(trainId)")
            print("startId = \(startTrainId)")
            let durationCsv = try! String(contentsOfFile: path2, encoding: String.Encoding.utf8)
            trainDurationList = durationCsv.components(separatedBy: .newlines)
            for durationData in trainDurationList {
                let durationDetail = durationData.components(separatedBy: ",")
                if((startTrainId-trainId) < 0) { //往路の場合
                    if(count == trainDurationList.count - 1){ break }
                    
                    if(trainId == 24 || trainId == 25 || trainId == 26 || startTrainId == 24 || startTrainId == 25 || startTrainId == 26) {
                        if(startTrainId <= count + 1 && count + 1 < trainId && (durationDetail[2] == "a" || durationDetail[2] == "c")){ //どつく前
                            
                            useTrainTime += Int(durationDetail[1])!
                            //  print(durationDetail[0])
                        }
                    }else if(trainId == 21 || trainId == 22 || trainId == 23 || startTrainId == 21 || startTrainId == 22 || startTrainId == 23) {
                        if(startTrainId <= count + 1 && count + 1 < trainId && (durationDetail[2] == "a" || durationDetail[2] == "b")){ //谷地頭
                            useTrainTime += Int(durationDetail[1])!
                            //  print(durationDetail[0])
                        }
                    }else {
                        if(startTrainId <= count + 1 && count + 1 < trainId && durationDetail[2] == "a"){ //分岐しない
                            useTrainTime += Int(durationDetail[1])!
                            //    print(durationDetail[0])
                        }
                    }
                    
                }else{
                    if(count == trainDurationList.count - 1){ break }
                    if(trainId == 24 || trainId == 25 || trainId == 26 || startTrainId == 24 || startTrainId == 25 || startTrainId == 26) {
                        if(trainId <= count + 1 && count + 1 < startTrainId && (durationDetail[2] == "a" || durationDetail[2] == "c")){ //どつく前
                            useTrainTime += Int(durationDetail[1])!
                            //   print(durationDetail[0])
                        }
                    }else if(trainId == 21 || trainId == 22 || trainId == 23 || startTrainId == 21 || startTrainId == 22 || startTrainId == 23) {
                        if(trainId <= count + 1 && count + 1 < startTrainId && (durationDetail[2] == "a" || durationDetail[2] == "b")){ //谷地頭
                            useTrainTime += Int(durationDetail[1])!
                            //  print(durationDetail[0])
                        }
                    }else {
                        if(trainId <= count + 1 && count + 1 < startTrainId && durationDetail[2] == "a"){ //分岐しない
                            useTrainTime += Int(durationDetail[1])!
                            //  print(durationDetail[0])
                        }
                    }
                }
                count += 1
            }
            print("useTrainTime=\(useTrainTime)")
            useTrainTimeList.append(useTrainTime) //電停間の所要時間を追加
            useTrainTime = 0
            
            print("useTrain = \(useTrainTimeList)")
        } catch let error as NSError {
            return
        }
    }
    
    func change_spot_number() { //現在地に近い順に目的スポットを入れ替える
        var latifabs: Double = 0
        var lonfabs: Double = 0
        var currentToSpot_fabs: [Double] = []
        var sort_waypoint_station = ""
        var sort_waypoint_station_key = ""
        
        for i in 0..<goalspot_lat_list.count {
            goalspot_key_list.append("\(goalspot_lat_list[i]),\(goalspot_lon_list[i])")
        }
        
        for i in 0..<goalspot_list.count {//現在地から最寄りの電停を求める
            latifabs = fabs(Double(current_lati)! - Double(goalspot_lat_list[i]))
            lonfabs = fabs(Double(current_lon)! - Double(goalspot_lon_list[i]))
            currentToSpot_fabs.append(latifabs + lonfabs) //現在地と目的スポットの距離を追加
        }
        
        print("currentfab=\(currentToSpot_fabs)")
        
        let sortfabs = currentToSpot_fabs.sorted()
        print("sortfabs=\(sortfabs)")
        for i in 0..<currentToSpot_fabs.count - 1 {
            print(currentToSpot_fabs.firstIndex(of: sortfabs[i])!)
            sortgoalspotList.append(goalspot_list[currentToSpot_fabs.firstIndex(of: sortfabs[i])!])
            sortgoalspotKeyList.append(goalspot_key_list[currentToSpot_fabs.firstIndex(of: sortfabs[i])!])
        }
        
        let finalgoal = goalspot_list[currentToSpot_fabs.firstIndex(of: sortfabs[currentToSpot_fabs.count - 1])!]
        let finalgoalkey = goalspot_key_list[currentToSpot_fabs.firstIndex(of: sortfabs[currentToSpot_fabs.count - 1])!]
        print(sortgoalspotList)
        print("最終目的地:\(finalgoal)")
        
        if(waypointList.count > 3) { //目的スポットが複数の場合
            var goalcount = 0
            sortwaypointList.append(waypointList[0])
            sortwaypointKeyList.append(waypointKeyList[0])
            for i in 0..<waypointList.count {
                if(waypointTypeList[i] != "t") {
                    print("t実行")
                    if(waypointList.firstIndex(of: sortgoalspotList[goalcount]) == nil) { //waypointListにない場合、目的地を追加
                        if(goalcount >= 1) {
                            sortwaypointList.append(sort_waypoint_station)
                            sortwaypointKeyList.append(sort_waypoint_station_key)
                            result_durication_trum(start: sort_waypoint_station, end: waypointList[waypointList.count-1])
                        }else{
                            result_durication_trum(start: sortwaypointList[0], end: waypointList[waypointList.count-1])
                        }
                        sort_waypoint_station = waypointList[waypointList.count-1]
                        sort_waypoint_station_key = waypointKeyList[waypointKeyList.count-1]
                        
                        sortwaypointList.append(sort_waypoint_station)
                        sortwaypointKeyList.append(sort_waypoint_station_key)
                        
                        sortwaypointList.append(sortgoalspotList[goalcount])
                        sortwaypointKeyList.append(sortgoalspotKeyList[goalcount])
                    }else{
                        let station_id = waypointList.firstIndex(of: sortgoalspotList[goalcount])!
                        if(goalcount >= 1) {
                            sortwaypointList.append(sort_waypoint_station)
                            sortwaypointKeyList.append(sort_waypoint_station_key)
                            result_durication_trum(start: sort_waypoint_station, end: waypointList[station_id - 1])
                        }else{
                            result_durication_trum(start: sortwaypointList[0], end: waypointList[station_id - 1])
                        }
                        sort_waypoint_station = waypointList[station_id - 1]
                        sort_waypoint_station_key = waypointKeyList[station_id - 1]
                        
                        sortwaypointList.append(sort_waypoint_station)
                        sortwaypointKeyList.append(sort_waypoint_station_key)
                        
                        sortwaypointList.append(sortgoalspotList[goalcount]) //元々のwaypopintListから一番目のスポットの要素番号を探す
                        sortwaypointKeyList.append(sortgoalspotKeyList[goalcount])
                    }
                    goalcount += 1
                }
            }
            sortwaypointList.append(sort_waypoint_station)
            sortwaypointKeyList.append(sort_waypoint_station_key)
            
            if(waypointList.firstIndex(of: finalgoal) == nil) {
                result_durication_trum(start: sort_waypoint_station, end: waypointList[waypointList.count-1])
                sortwaypointList.append(waypointList[waypointList.count-1])
                sortwaypointKeyList.append(waypointKeyList[waypointKeyList.count-1])
            }else{
                result_durication_trum(start: sort_waypoint_station, end: waypointList[waypointList.firstIndex(of: finalgoal)! - 1])
                sortwaypointList.append(waypointList[waypointList.firstIndex(of: finalgoal)! - 1])
                sortwaypointKeyList.append(waypointKeyList[waypointList.firstIndex(of: finalgoal)! - 1])
            }
        }
        self.endField.text = finalgoal
        endSpotKey = finalgoalkey
        print("waypointList = \(waypointList)")
        print("waykey=\(waypointKeyList)")
        print("sortwayKey=\(sortwaypointKeyList)")
        print("sort後: waypointList = \(sortwaypointList)")
        print("時間=\(useTrainTimeList)")
    }
    
    func result_stationTime() { //最寄りの駅に到着後最も近い到着時刻を算出
        let dt = Date()
        let dayTypeFormatter = DateFormatter() //曜日を出力する
        dayTypeFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE", options: 0, locale: Locale(identifier: "ja_JP"))
        let currentdayType = dayTypeFormatter.string(from: dt)
        var count = 0
        guard let path1 = Bundle.main.path(forResource:"stop_times", ofType:"csv") else {
            return
        }
        do {
            //現在時刻に最も近い電停の到着時刻を求める。
            let timecsv = try String(contentsOfFile: path1, encoding: String.Encoding.utf8)
            timeDataList = timecsv.components(separatedBy: .newlines)
            timeDataList.removeLast()
            
            for i in 0 ..< timeDataList.count {
                if(i < timeDataList.count - 1){
                    if i % 2 != 1 {
                        timeDataList_re.append(timeDataList[i])
                    }
                }
            }
            for timeData in timeDataList_re {
                let timeDetail = timeData.components(separatedBy: ",")
                let tableType = timeDetail[0]
                if((startTrainId-trainId) < 0){ //往路の場
                    if(currentdayType == "Sunday" || currentdayType  == "Saturday")  {//土日の場合
                        if(trainId == 24 || trainId == 25 || trainId == 26) {
                            if(tableType.contains("HKD5_土日祝（往）")){
                                if(currentTime < timeDetail[1] && timeDetail[3].contains("\(trainId)")) {
                                    timeTableCount += 1
                                    print(timeDetail)
                                    if(timeTableCount == 1) {
                                        stationTime = timeDetail[1]
                                        stationHour = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 0)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 1)])")!
                                        stationMinute = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 3)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 4)])")!
                                        break
                                    }
                                }
                            }
                        }else if(trainId == 21 || trainId == 22 || trainId == 23) {
                            if(tableType.contains("HKD2_土日祝（往）")){
                                if(currentTime < timeDetail[1] && timeDetail[3].contains("\(trainId)")) {
                                    timeTableCount += 1
                                    print(timeDetail)
                                    if(timeTableCount == 1) {
                                        stationTime = timeDetail[1]
                                        stationHour = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 0)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 1)])")!
                                        stationMinute = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 3)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 4)])")!
                                        break
                                    }
                                }
                            }
                        }else {
                            if(tableType.contains("HKD5_土日祝（往）")){
                                if(currentTime < timeDetail[1] && timeDetail[3].contains("\(trainId)")) {
                                    timeTableCount += 1
                                    print(timeDetail)
                                    if(timeTableCount == 1) {
                                        stationTime = timeDetail[1]
                                        stationHour = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 0)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 1)])")!
                                        stationMinute = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 3)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 4)])")!
                                        break
                                    }
                                }
                            }
                        }
                    } else { //平日の場合
                        if(trainId == 24 || trainId == 25 || trainId == 26) {
                            if(tableType.contains("HKD5_平日（往）")){
                                if(currentTime < timeDetail[1] && timeDetail[3].contains("\(trainId)")) {
                                    timeTableCount += 1
                                    print(timeDetail)
                                    if(timeTableCount == 1) {
                                        stationTime = timeDetail[1]
                                        stationHour = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 0)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 1)])")!
                                        stationMinute = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 3)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 4)])")!
                                        break
                                    }
                                }
                            }
                        }else if(trainId == 21 || trainId == 22 || trainId == 23) {
                            if(tableType.contains("HKD2_平日（往）")){
                                if(currentTime < timeDetail[1] && timeDetail[3].contains("\(trainId)")) {
                                    timeTableCount += 1
                                    print(timeDetail)
                                    if(timeTableCount == 1) {
                                        stationTime = timeDetail[1]
                                        stationHour = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 0)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 1)])")!
                                        stationMinute = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 3)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 4)])")!
                                        break
                                    }
                                }
                            }
                        }else {
                            if(tableType.contains("HKD5_平日（往）")){
                                if(currentTime < timeDetail[1] && timeDetail[3].contains("\(trainId)")) {
                                    timeTableCount += 1
                                    print(timeDetail)
                                    if(timeTableCount == 1) {
                                        stationTime = timeDetail[1]
                                        stationHour = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 0)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 1)])")!
                                        stationMinute = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 3)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 4)])")!
                                        break
                                    }
                                }
                            }
                        }
                    }
                } else { //復路の場合
                    if(currentdayType == "Sunday" || currentdayType  == "Saturday")  {
                        if(trainId == 24 || trainId == 25 || trainId == 26) {
                            if(tableType.contains("HKD5_土日祝（復）")){
                                if(currentTime < timeDetail[1] && timeDetail[3].contains("\(trainId)")) {
                                    timeTableCount += 1
                                    print(timeDetail)
                                    if(timeTableCount == 1) {
                                        stationTime = timeDetail[1]
                                        stationHour = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 0)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 1)])")!
                                        stationMinute = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 3)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 4)])")!
                                        break
                                    }
                                }
                            }
                        }else if(trainId == 21 || trainId == 22 || trainId == 23) {
                            if(tableType.contains("HKD2_土日祝（復）")){
                                if(currentTime < timeDetail[1] && timeDetail[3].contains("\(trainId)")) {
                                    timeTableCount += 1
                                    print(timeDetail)
                                    if(timeTableCount == 1) {
                                        stationTime = timeDetail[1]
                                        stationHour = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 0)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 1)])")!
                                        stationMinute = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 3)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 4)])")!
                                        break
                                    }
                                }
                            }
                        }else {
                            if(tableType.contains("HKD5_土日祝（復）")){
                                if(currentTime < timeDetail[1] && timeDetail[3].contains("\(trainId)")) {
                                    timeTableCount += 1
                                    print(timeDetail)
                                    if(timeTableCount == 1) {
                                        stationTime = timeDetail[1]
                                        stationHour = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 0)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 1)])")!
                                        stationMinute = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 3)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 4)])")!
                                        break
                                    }
                                }
                            }
                        }
                    } else {
                        if(trainId == 24 || trainId == 25 || trainId == 26) {
                            if(tableType.contains("HKD5_平日（復）")){
                                if(currentTime < timeDetail[1] && timeDetail[3].contains("\(trainId)")) {
                                    timeTableCount += 1
                                    print(timeDetail)
                                    if(timeTableCount == 2) {
                                        stationTime = timeDetail[1]
                                        stationHour = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 0)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 1)])")!
                                        stationMinute = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 3)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 4)])")!
                                        break
                                    }
                                }
                            }
                        }else if(trainId == 21 || trainId == 22 || trainId == 23) {
                            if(tableType.contains("HKD2_平日（復）")){
                                if(currentTime < timeDetail[1] && timeDetail[3].contains("\(trainId)")) {
                                    timeTableCount += 1
                                    print(timeDetail)
                                    if(timeTableCount == 2) {
                                        stationTime = timeDetail[1]
                                        stationHour = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 0)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 1)])")!
                                        stationMinute = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 3)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 4)])")!
                                        break
                                    }
                                }
                            }
                        }else {
                            if(tableType.contains("HKD5_平日（復）")){
                                if(currentTime < timeDetail[1] && timeDetail[3].contains("\(trainId)")) {
                                    timeTableCount += 1
                                    print(timeDetail)
                                    if(timeTableCount == 2) {
                                        stationTime = timeDetail[1]
                                        stationHour = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 0)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 1)])")!
                                        stationMinute = Int("\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 3)])\(stationTime[stationTime.index(stationTime.startIndex, offsetBy: 4)])")!
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }catch let error as NSError {
            return
        }
        timeTableCount = 0
    }
}

