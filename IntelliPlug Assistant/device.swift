//
//  device.swift
//  IntelliPlug Assistant
//
//  Created by tobias lüscher on 08.08.16.
//  Copyright © 2016 IntelliPlug. All rights reserved.
//

import Foundation
import RealmSwift

class Device: Object {
    
    dynamic var dbID: String = ""
    dynamic var deviceID: Int64 = 0
    dynamic var name: String = ""
    dynamic var adress: String = ""
    dynamic var user: DeviceUser? = DeviceUser()
}
