//
//  user.swift
//  IntelliPlug Assistant
//
//  Created by tobias lüscher on 05.09.16.
//  Copyright © 2016 IntelliPlug. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    
    dynamic var username: String = ""
    dynamic var password: String = ""
    dynamic var email: String = ""
}
