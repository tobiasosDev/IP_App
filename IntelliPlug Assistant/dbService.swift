//
//  dbService.swift
//  IntelliPlug Assistant
//
//  Created by tobias lüscher on 25.08.16.
//  Copyright © 2016 IntelliPlug. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import PromiseKit
import Gloss

class dbService: NSObject {
    let RequestParameters = EnumService.RequestParameters.self
    
    func checkLoginData(_ username: String, password: String) -> Promise<String>{
        return Promise { fulfill, reject in
            Alamofire.request("http://node.lscher.com/intelliplug/auth").authenticate(user: username, password: password).responseString { response in
                switch response.result {
                case .success(let dict):
                    print("---------------Authorized-------------")
                    print(response.result.value ?? "Authorized")
                    fulfill(dict)
                case .failure(let error):
                    print("---------------Unauthorized-------------")
                    print(response.result)
                    reject(error)
                }
            }
            
        }
        
    }
    
    func createLoginHeaders() -> [String : String]{
        let userData = getLoginData()
        let user: String = userData.username
        let password: String = userData.password
        let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        return headers
    }
    
    func getLoginData() -> User {
        let realm = try! Realm()
        var user = realm.objects(User.self).first
        //Problem with nil to fix that i wrote a little hack, could be better
        if(user == nil){
            user = User()
        }
        return user!
    }
    
    func deleteLoginData(){
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(User.self))
        }
    }
    
    func setLoginData(_ username: String!, password: String!, email: String!) {
        let realm = try! Realm()
        let userData: User = User()
        userData.username = username
        userData.email = email
        userData.password = password
        try! realm.write{
            realm.add(userData)
        }
    }
    
    func deletePlugByName(_ id: String) -> Promise<String> {
        return Promise { fulfill, reject in
            Alamofire.request("http://node.lscher.com/intelliplug/deletePlug", method: .delete, parameters: ["\(RequestParameters.id)": id], encoding: JSONEncoding.default, headers: createLoginHeaders()).validate()
                .responseString { response in
                    switch response.result {
                    case .success(let dict):
                        fulfill(dict)
                    case .failure(let error):
                        reject(error)
                    }
            }
            
        }
    }
    
    
    func getData() -> Promise<NSArray> {
        let realm = try! Realm()
        return Promise { fulfill, reject in
            Alamofire.request("http://node.lscher.com/intelliplug", parameters: ["\(RequestParameters.name)": "test"], encoding: URLEncoding.default, headers: createLoginHeaders()).validate().responseJSON { response in
                print(response.result)
                switch response.result {
                case .success(let dict):
                    let jsonSerialized: [JSON] = response.result.value as! [JSON]
                    let deviceJsonSeriliazed = [DeviceJson].fromJSONArray(jsonArray: jsonSerialized)
                    for (deviceJsonElement):(DeviceJson) in deviceJsonSeriliazed! {
                        if(realm.objects(Device.self).filter("dbID == '\(deviceJsonElement.dbID!)'").count == 0){
                            let myUser: DeviceUser = DeviceUser()
                            myUser.email = (deviceJsonElement.user.email)!
                            myUser.name = (deviceJsonElement.user.name)!
                            let myDevice: Device = Device()
                            myDevice.name = deviceJsonElement.name!
                            myDevice.adress = deviceJsonElement.adress!
                            myDevice.deviceID = deviceJsonElement.deviceID!
                            myDevice.user = myUser
                            myDevice.dbID = deviceJsonElement.dbID!
                            try! realm.write {
                                realm.add(myDevice)
                            }
                        }
                    }
                    fulfill(dict as! NSArray)
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }
    
    func getPlugById(plugId id: String) -> Promise<NSArray> {
        let realm = try! Realm()
        return Promise { fulfill, reject in
            Alamofire.request("http://node.lscher.com/intelliplug", parameters: ["\(RequestParameters.id)": id], encoding: URLEncoding.default, headers: createLoginHeaders()).validate().responseJSON { response in
                print(response.result)
                switch response.result {
                case .success(let dict):
                    let jsonSerialized: [JSON] = response.result.value as! [JSON]
                    let deviceJsonSeriliazed = [DeviceJson].fromJSONArray(jsonArray: jsonSerialized)
                    for (deviceJsonElement):(DeviceJson) in deviceJsonSeriliazed! {
                        let realmDevice = realm.objects(Device.self).filter("dbID == '\(deviceJsonElement.dbID!)'").first!
                        let myUser: DeviceUser = DeviceUser()
                        myUser.email = (deviceJsonElement.user.email)!
                        myUser.name = (deviceJsonElement.user.name)!
                        try! realm.write {
                            realmDevice.name = deviceJsonElement.name!
                            realmDevice.adress = deviceJsonElement.adress!
                            realmDevice.deviceID = deviceJsonElement.deviceID!
                            realmDevice.user = myUser
                            realmDevice.dbID = deviceJsonElement.dbID!
                        }
                    }
                    fulfill(dict as! NSArray)
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }
    
    func insertPlug(_ name: String, UUID: NSUUID) -> Promise<String> {
        return Promise { fulfill, reject in
            Alamofire.request("http://node.lscher.com/intelliplug/insertPlugs", method: .post, parameters: ["\(RequestParameters.name)": name, "\(RequestParameters.adress)": UUID.uuidString], encoding: JSONEncoding.default, headers: createLoginHeaders()).validate()
                .responseString { response in
                    switch response.result {
                    case .success(let dict):
                        fulfill(dict)
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    
    func updatePlug(dbId id: String, updateEnum: String, updateValue val: String) -> Promise<String> {
        return Promise { fulfill, reject in
            Alamofire.request("http://node.lscher.com/intelliplug/updatePlug", method: .post, parameters: ["\(RequestParameters.id)": id, "\(RequestParameters.updateEnum)": updateEnum, "\(RequestParameters.updateValue)": val], encoding: JSONEncoding.default, headers: createLoginHeaders()).validate()
                .responseString { response in
                    switch response.result {
                    case .success(let dict):
                        _ = self.getPlugById(plugId: id)
                        fulfill(dict)
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
}



