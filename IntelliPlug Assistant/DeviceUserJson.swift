//
//  UserDeviceJson.swift
//  IntelliPlug Assistant
//
//  Created by tobias lüscher on 14.09.16.
//  Copyright © 2016 ch.intelliplug. All rights reserved.
//

import Gloss

struct DeviceUserJson: Glossy {
    
    var name: String?
    var email: String?
    
    // MARK: - Deserialization
    
    init?(json: JSON) {
        self.name = ("name" <~~ json)!
        self.email = ("email" <~~ json)!
    }
    
    // MARK: - Serialization
    
    func toJSON() -> JSON? {
        return jsonify(array: [
            "name" ~~> self.name,
            "email" ~~> self.email
            ])
    }
    
}
