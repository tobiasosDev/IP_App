//
//  EnumService.swift
//  IntelliPlug Assistant
//
//  Created by tobias lüscher on 06.10.16.
//  Copyright © 2016 ch.intelliplug. All rights reserved.
//

import Foundation

class EnumService{
    
    enum IntelliPlugModel{
        case id
        case name
        case adress
        case user
    }
    
    enum RequestParameters{
        case updateEnum
        case updateValue
        case id
        case name
        case adress
        case deviceID
        case val
        case date
    }

}
