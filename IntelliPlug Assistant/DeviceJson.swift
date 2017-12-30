//
//  deviceJson.swift
//  IntelliPlug Assistant
//
//  Created by tobias lüscher on 14.09.16.
//  Copyright © 2016 ch.intelliplug. All rights reserved.
//

import Gloss

struct DeviceJson: Decodable {
    var dbID: String?
    var deviceID: Int64?
    var name: String?
    var adress: String?
    var user: DeviceUserJson
    
    
    // MARK: - Deserialization
    
    init?(json: JSON) {
        self.dbID = ("_id" <~~ json)!
        self.deviceID = ("id" <~~ json)!
        self.name = ("name" <~~ json)!
        self.adress = ("adress" <~~ json)!
        self.user = DeviceUserJson(json: ("user" <~~ json)!)!
    }
}
