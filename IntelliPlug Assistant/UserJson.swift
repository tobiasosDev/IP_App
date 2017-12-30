//
//  UserJson.swift
//  IntelliPlug Assistant
//
//  Created by tobias lüscher on 14.09.16.
//  Copyright © 2016 ch.intelliplug. All rights reserved.
//

import Gloss

struct UserJson: Decodable {
    var name: String?
    var password: String?
    var email: String?
    
    
    // MARK: - Deserialization
    
    init?(json: JSON) {
        self.name = ("name" <~~ json)!
        self.password = ("password" <~~ json)!
        self.email = ("email" <~~ json)!
    }
}
