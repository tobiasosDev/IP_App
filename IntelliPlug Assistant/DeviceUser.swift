//
//  DeviceUser.swift
//  IntelliPlug Assistant
//
//  Created by tobias lüscher on 14.09.16.
//  Copyright © 2016 ch.intelliplug. All rights reserved.
//

import Foundation
import RealmSwift

class DeviceUser: Object {
    
    dynamic var name: String = ""
    dynamic var email: String = ""
}
