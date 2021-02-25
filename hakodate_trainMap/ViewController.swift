    //
    //  ViewController.swift
    //  hakodate_trainMap
    //
    //  Created by 宮下翔伍 on 2020/05/19.
    //  Copyright © 2020 宮下翔伍. All rights reserved.
    //
    
    import UIKit
    import MapKit
    import CoreLocation
    
    var spot_type:[String] = [""]
    var spot_type_tap: String = ""
    var spot_id: [Int]  = [0]
    var spot_id_tap: Int = 0
    var spot_title:[String] = [""]
    var spot_title_tap:String = ""
    var hkd2_type = ["HKD2_平日（往）","HKD2_平日（復）","HKD2_土日祝（往）","HKD2_土日祝（復）"]
    var hkd5_type = ["HKD5_平日（往）","HKD5_平日（復）","HKD5_土日祝（往）","HKD5_土日祝（復）"]
    var spot_lat:[CLLocationDegrees] = [0]
    var spot_lat_tap: CLLocationDegrees = 0
    var spot_lon:[CLLocationDegrees] = [0]
    var spot_lon_tap: CLLocationDegrees = 0
    var spot_url: [String] = [""]
    var spot_url_tap: String = ""
    var timeTableList:[String] = []
    var stationName = ""
    var stationNameList: [String] = [] //ピンの表示に使用
    var timeTableId = 0
    var startTrain = 0
    var start_goal_idList:[Int] = []
    var check = ""
    var tapSpot: String = ""
    var station_lat: CLLocationDegrees = 0
    var station_lon: CLLocationDegrees = 0
    var station_lat_list: [CLLocationDegrees] = [] //ピンの表示に使用
    var station_lon_list: [CLLocationDegrees] = []
    var editmode = "go"
    var currentNearStation = ""
    var save_current_lati = ""
    var save_current_lon = ""
    var current_lati = ""
    var current_lon = ""
    var last_went_station = ""
    var last_went_station_key = ""
    var goalspot_list: [String] = []
    var goalspot_lon_list: [CLLocationDegrees] = [] //現在地に近い順に目的地を入れ替えるときに使用
    var goalspot_lat_list: [CLLocationDegrees] = []
    var goalspot_key_list: [String] = []
    var stationNameData: [String] = []
    
    class ViewController: UIViewController, CLLocationManagerDelegate {
        
        @IBOutlet weak var schedulerButton: UIButton! {
            didSet {
                schedulerButton.addTarget(self, action: #selector(tappedSchedule), for: .touchDown)
            }
        }
        
        @IBOutlet weak var mapView: MKMapView! {
            didSet {
                mapView.delegate = self
            }
        }
        var polylinecount = 0
        var step_check = 0
        var latitude = ""
        var longitude = ""
        var locationManager: CLLocationManager!
        var minStation: Int = 0
        var signal = 0
        var gurumeDataList = [String]()
        var asobiDataList = [String]()
        var trainDataList = [String]()
        var timeDataList = [String]()
        var timeDataList_re = [String]()
        var trainStationLati: [Double] = []
        var trainStationLon: [Double] = []
        var url:URL?
        var sub = ""
        var trainImage: UIImage = UIImage(named: "train")!
        var latifabs: Double = 0 //現在地から最寄りの電停を求めるためのlatitudeの差分絶対値
        var lonfabs: Double = 0 //現在地から最寄りの電停を求めるためのlongitudeの差分絶対値
        var fabsList: [Double] = []
        // var gotoButton = UIButton(type: UIButton.ButtonType.infoLight)
        var gurumeUrlList:[String] = []
        var asobiUrlList:[String] = []
        var currentAno: [MKAnnotation] = []
        var mode = "map"
        let detailButton = UIButton(type: UIButton.ButtonType.infoLight)
        
        func addAno(_ type:String,_ id:Int,_ latitude:CLLocationDegrees,_ longitude: CLLocationDegrees,_ title:String,_ subtitle: String){
            let ano = custumAno(type:type,id: id, coordinate: CLLocationCoordinate2DMake(latitude,longitude), title: title, subtitle: subtitle)
            mapView.delegate = self
            if(ano.type == "a" || ano.type == "g"){
                currentAno.append(ano)
            }
            self.mapView.addAnnotation(ano)
        }
        
        @objc func tappedSchedule() {
            if makeSignal == false {
                self.performSegue(withIdentifier: "toRouteView", sender: nil)
            }else {
                self.performSegue(withIdentifier: "fromMaptoScheduleView", sender: nil)
            }
        }
        
        @objc func tappedSearchView() {
            if(editmode == "add") {
                var goal_spot_key = endSpotKey
                var goal_spot = endPoint
                endSpotKey = "\(spot_lat_tap),\(spot_lon_tap)"
                endPoint = tapSpot
                waypointList.append(goal_spot)
                goalspot_list.append(tapSpot)
                goalspot_lat_list.append(spot_lat_tap)
                goalspot_lon_list.append(spot_lon_tap)
                waypointKeyList.append(goal_spot_key)
                waypointTypeList.append(check)
            }
            
            spot_type.append(spot_type_tap)
            spot_id.append(spot_id_tap)
            spot_title.append(spot_title_tap)
            spot_lat.append(spot_lat_tap)
            spot_lon.append(spot_lon_tap)
            spot_url.append(spot_url_tap)
            
            stationNameList.append(stationName)
            station_lat_list.append(station_lat)
            station_lon_list.append(station_lon)
            startPoint = "\(current_lati), \(current_lon)"
            endSpotKey = "\(spot_lat_tap), \(spot_lon_tap)"
            for i in 0..<trainStationLati.count {//現在地から最寄りの電停を求める
                latifabs = fabs(Double(current_lati)! - trainStationLati[i])
                lonfabs = fabs(Double(current_lon)! - trainStationLon[i])
                fabsList.append(latifabs + lonfabs) //現在地と各電停間の距離を追加
            }
            
            let minFabs = fabsList.min()
            minStation = fabsList.firstIndex(of: minFabs!)!
          //  print(minStation)
            station_lat_list.append(trainStationLati[minStation])
            station_lon_list.append(trainStationLon[minStation])
            if(editmode != "add"){
                startTrain = minStation + 1
                start_goal_idList.append(startTrain)
            } else {
                startTrain = start_mid_id
                start_goal_idList.append(startTrain)
            }
            start_goal_idList.append(timeTableId)
            currentNearStation = stationNameData[minStation]
            stationNameList.append(currentNearStation) //ピンに追加
            if(editmode == "add"){
                waypointList.append(last_went_station)
                waypointKeyList.append(last_went_station_key)
            } else {
                goalspot_list.append(tapSpot)
                goalspot_lat_list.append(spot_lat_tap)
                goalspot_lon_list.append(spot_lon_tap)
                waypointList.append(currentNearStation)
               // waypointTypeList.append(check)
                waypointKeyList.append("\(trainStationLati[minStation]),\(trainStationLon[minStation])")
            }
            save_current_lati = current_lati
            save_current_lon = current_lon
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let popupView: PopupViewController = storyBoard.instantiateViewController(withIdentifier: "PopupView") as! PopupViewController
            popupView.modalPresentationStyle = .overFullScreen
            popupView.modalTransitionStyle = .crossDissolve
            
            self.present(popupView, animated: false, completion: nil)
            //  self.performSegue(withIdentifier: "toRouteView", sender: nil)
        }
        @objc func showDetail() {
            if check != "t" {
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!)
                }
            }else{
                timeDataList.removeAll()
                timeDataList_re.removeAll()
                guard let path1 = Bundle.main.path(forResource:"stop_times", ofType:"csv")else {
                    return
                }
                do {
                    //時刻表のデータ
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
                    
                    var perseTime = 6
                    var hourTime = ""
                    for timeData in timeDataList_re {
                        let timeDetail = timeData.components(separatedBy: ",")
                        if(timeDetail[3] == "\(timeTableId)_2" && timeDetail[0].contains(hkd2_type[2])){
                            if timeDetail[2].contains("\(perseTime)") {
                                hourTime += timeDetail[2].prefix(5) + "  "
                            }else{
                                timeTableList.append(hourTime)
                                perseTime += 1
                                hourTime = timeDetail[2].prefix(5) + "  "
                            }
                        }
                    }
                } catch let error as NSError {
                    return
                }
                self.performSegue(withIdentifier: "toTimeTableView", sender: nil)
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            if (save_current_lon != "" && save_current_lati != "") {
                current_lati = save_current_lati
                current_lon = save_current_lon
            }
            self.addAno("current", 0, Double(current_lati)!, Double(current_lon)!, "現在地", "")
            schedulerButton.isHidden = true
            if(startPositionList.count != 0 ){
                for i in 0..<startPositionList.count {
                    let coordinates = [startPositionList[i], endPositionList[i]]
                    let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
                
                    self.mapView.addOverlay(polyLine)
                }
            } else {
                for overlay in mapView.overlays {
                    self.mapView.removeOverlay(overlay)
                }
            }
            
            let center = CLLocationCoordinate2D(latitude: 41.7687933, longitude:140.7288103)
            let span : MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region : MKCoordinateRegion = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
            mapView.setUserTrackingMode(.follow, animated: true)
            guard let path1 = Bundle.main.path(forResource:"stop_times", ofType:"csv"), let path3 = Bundle.main.path(forResource:"train", ofType:"csv")else {
                return
            }
            do {
                //市電のデータ
                if(makeSignal == false) {
                    let csvTrain = try String(contentsOfFile: path3, encoding: String.Encoding.utf8)
                    trainDataList = csvTrain.components(separatedBy: .newlines)
                    trainDataList.removeLast()
                    print(trainDataList.count)
                    for trainData in trainDataList {
                        let trainDetail = trainData.components(separatedBy: ",")
                        //print(trainData)
                        self.addAno(trainDetail[0],Int(trainDetail[1])!,Double(trainDetail[3])!, Double(trainDetail[4])!, trainDetail[2],sub)
                        trainStationLati.append(Double(trainDetail[3])!)
                        trainStationLon.append(Double(trainDetail[4])!)
                        stationNameData.append(trainDetail[2])
                    }
                    
                    print(stationNameData)
                    print(trainStationLon)
                    //時刻表のデータ
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
                }else{ //ルート表示の場合
                //step_check = stepList.count
                    mode = "route"
                    schedulerButton.isHidden = false
                    print("電停表示")
                    //self.addAno("t",14,41.7892585,140.7522832,"五稜郭公園前駅", sub)
                    for i  in 0..<start_goal_idList.count {
                        self.addAno("t", start_goal_idList[i], station_lat_list[i], station_lon_list[i], stationNameList[i], sub)
                    }
                    
                    for i in 0..<spot_id.count {
                        self.addAno(spot_type[i],spot_id[i], spot_lat[i], spot_lon[i], spot_title[i], sub)
                    }
                    
                    let csvTrain = try String(contentsOfFile: path3, encoding: String.Encoding.utf8)
                    trainDataList = csvTrain.components(separatedBy: .newlines)
                    trainDataList.removeLast()
                    print(trainDataList.count)
                    for trainData in trainDataList {
                        let trainDetail = trainData.components(separatedBy: ",")
                        // print(trainData)
                        if(Int(trainDetail[1]) == timeTableId) {
                            self.addAno(trainDetail[0],Int(trainDetail[1])!,Double(trainDetail[3])!, Double(trainDetail[4])!, trainDetail[2],sub)
                        }
                    }
                }
            } catch let error as NSError {
                return
            }
        }
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toRouteView" {
                let nV = segue.destination as! routeViewController
                if(editmode != "add") {
                    endPoint = tapSpot
                }
                nV.trainId = timeTableId
            }
        }
        
    }
    extension ViewController: MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let polylineRenderer = MKPolylineRenderer(polyline: polyline)
                print("poly\(step_check)")
                print("polycount\(polylinecount)")
                if(step_check < stepList.count) {
                    if(polylinecount < stepList[step_check]) {
                        polylineRenderer.strokeColor = polylineColor[step_check]
                    }else{
                        polylinecount = 0
                        step_check += 1
                    }
                }
                polylineRenderer.lineWidth = 4.0
                polylinecount += 1
                return polylineRenderer
            }
            return MKOverlayRenderer()
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
        -> MKAnnotationView? {
            if annotation.title == "My Location"{
                return nil
            }
            let identifier = "Pin"
            let gotoButton = UIButton()
            gotoButton.frame = CGRect(x:0,y:0,width:40,height:40)
            if(editmode == "go") {
                gotoButton.setImage(UIImage(named: "goImage"), for: .normal)
            }else {
                gotoButton.setImage(UIImage(named: "addImage"), for: .normal)
            }
            var pinview = MKAnnotationView(annotation: annotation, reuseIdentifier:nil)
            pinview = MKAnnotationView.init(annotation: annotation, reuseIdentifier: identifier)
            pinview.canShowCallout = true  // タップで吹き出しを表示
            if(mode != "route") {
            pinview.rightCalloutAccessoryView = detailButton
            pinview.leftCalloutAccessoryView = gotoButton
            }
            let ano:custumAno = annotation as! custumAno
            switch ano.type {
            case "a":
                trainImage = UIImage.init(named: "asobi")!
            case "g":
                trainImage = UIImage.init(named: "gurume")!
            case "current":
                trainImage = UIImage.init(named: "currentPosition")!
            default:
                trainImage = UIImage.init(named: "train")!
            }
            
            pinview.image = trainImage
            
            detailButton.addTarget(self, action: #selector(showDetail), for: .touchDown)
            gotoButton.addTarget(self, action: #selector(tappedSearchView), for: .touchDown)
            return pinview
        }
        // 選択された際に入る
        func mapView(_ mapView : MKMapView,didSelect view : MKAnnotationView){
            if view.annotation?.title == "My Location"{
                return
            }
            
            let ano:custumAno = view.annotation as! custumAno
            
            switch ano.type {
            case "a":
                if(mode != "route") {
                view.leftCalloutAccessoryView?.isHidden = false
                spot_type_tap = ano.type!
                spot_id_tap = ano.id!
                spot_title_tap = ano.title!
                spot_lon_tap = ano.coordinate.longitude
                spot_lat_tap = ano.coordinate.latitude
                spot_url_tap = asobiUrlList[ano.id!]
                check = ano.type!
                url = URL(string: asobiUrlList[ano.id!])
                tapSpot = ano.title!
                print(url)
                }else{
                    
                }
            case "g":
                if(mode != "route") {
                spot_type_tap = ano.type!
                spot_id_tap = ano.id!
                spot_title_tap = ano.title!
                spot_lon_tap = ano.coordinate.longitude
                spot_lat_tap = ano.coordinate.latitude
                spot_url_tap = gurumeUrlList[ano.id!]
                view.leftCalloutAccessoryView?.isHidden = false
                check = ano.type!
                url = URL(string: gurumeUrlList[ano.id!])
                print(url)
                print(ano.id!)
                print(gurumeUrlList[ano.id!])
                tapSpot = ano.title!
                }else{
                    
                }
            default:
                check = ano.type!
                timeTableId = ano.id!
                stationName = ano.title!
                station_lat = ano.coordinate.latitude
                station_lon = ano.coordinate.longitude
                print(timeTableId)
                
                view.leftCalloutAccessoryView?.isHidden = true
                guard let path1 = Bundle.main.path(forResource:"gurume", ofType:"csv"),let path2 = Bundle.main.path(forResource:"asobi", ofType:"csv")else {
                    return
                }
                do {
                    if(mode != "route") {
                    //グルメのデータ
                    let csvGurume = try! String(contentsOfFile: path1, encoding: String.Encoding.utf8)
                    gurumeDataList = csvGurume.components(separatedBy: .newlines)
                    gurumeDataList.removeLast()
                    self.mapView.removeAnnotations(currentAno)
                    var count = 0
                    for gurumeData in gurumeDataList {
                        let gurumeDetail = gurumeData.components(separatedBy: ",")
                        gurumeUrlList.append(gurumeDetail[5])
                        print(gurumeDetail[3])
                        if(fabs(ano.coordinate.latitude - Double(gurumeDetail[3])!) <= 0.01 && fabs(ano.coordinate.longitude - Double(gurumeDetail[4])!) <= 0.005){
                            count += 1
                            self.addAno(gurumeDetail[0],Int(gurumeDetail[1])!,Double(gurumeDetail[3])!, Double(gurumeDetail[4])!, gurumeDetail[2],"")
                        }
                    }
                    //遊びのデータ
                    let csvAsobi = try! String(contentsOfFile: path2, encoding: String.Encoding.utf8)
                    asobiDataList = csvAsobi.components(separatedBy: .newlines)
                    asobiDataList.removeLast()
                    for asobiData in asobiDataList {
                        let asobiDetail = asobiData.components(separatedBy: ",")
                        asobiUrlList.append(asobiDetail[5])
                        if(fabs(ano.coordinate.latitude - Double(asobiDetail[3])!) <= 0.01 && fabs(ano.coordinate.longitude - Double(asobiDetail[4])!) <= 0.005){
                            count += 1
                            self.addAno(asobiDetail[0],Int(asobiDetail[1])!,Double(asobiDetail[3])!, Double(asobiDetail[4])!, asobiDetail[2],"")
                        }
                    }
                    sub = ""
                    self.addAno(ano.type!, ano.id!, ano.coordinate.latitude, ano.coordinate.longitude, ano.title!, sub)
                    }
                }
            }
        }
    }
    
    class custumAno: NSObject,MKAnnotation {
        var coordinate: CLLocationCoordinate2D
        public var type: String?
        public var id: Int?
        public var title: String?
        public var subtitle: String?
        
        init(type: String,id: Int,coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
            self.type = type
            self.id = id
            self.coordinate = coordinate
            self.title = title
            self.subtitle = subtitle
            super.init()
        }
    }

    var polylineColor: [UIColor] = [.blue, .orange, .green, .red, .yellow]
