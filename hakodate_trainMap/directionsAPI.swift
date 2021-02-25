//
//  directionsAPI.swift
//  hakodate_trainMap
//
//  Created by 宮下翔伍 on 2020/06/11.
//  Copyright © 2020 宮下翔伍. All rights reserved.
//

import Foundation

struct directionAPI: Codable {
    let geocoded_waypoints: [waypoints]
    let status: String
    let routes: [routes]
}

struct waypoints: Codable {
    let geocoder_status: String
    let place_id: String
    let types: [String]
}
struct routes: Codable {
    let bounds: bounds
    let copyrights: String
    let legs: [legs]
}

struct bounds: Codable {
    struct northeast: Codable {
        let lat: Double
        let lng: Double
    }
    struct southhwest {
        let lat: Double
        let lng: Double
    }
}

struct legs: Codable {
    let distance: distance
    let duration: duration
    let end_address: String
    let end_location: end_location
    let start_address: String
    let start_location: start_location
    let steps: [steps]
}

struct steps: Codable {
    let distance: distance
    let duration: duration
    let end_location: end_location
    let html_instructions: String
    let polyline: polyline
    let start_location: start_location
    let travel_mode: String
}

struct distance: Codable { //legs
    let text: String
    let value: Int
}
struct polyline: Codable {
    let points: String
}
struct duration: Codable { //legs
    let text: String
    let value: Int
}
struct end_location:Codable { //legs
       let lat: Double
       let lng: Double
}
struct start_location: Codable { //legs
    let lat: Double
    let lng: Double
}
