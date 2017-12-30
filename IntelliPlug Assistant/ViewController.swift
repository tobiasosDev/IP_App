//
//  ViewController.swift
//  IntelliPlug Assistant
//
//  Created by tobias lüscher on 05.08.16.
//  Copyright © 2016 IntelliPlug. All rights reserved.
//

import UIKit
import RealmSwift
import PromiseKit
//Not available at the moment
// import Charts

class ViewController: UIViewController, UITextFieldDelegate {
    
    var checkIfRegisterd: Bool = false
    let colorServiceInstance = colorService()
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.layer.cornerRadius = 16
        passwordTextField.layer.cornerRadius = 16
        loginButton.layer.cornerRadius = 16
        
        //UITextField delegation
        self.usernameTextField.delegate = self;
        self.passwordTextField.delegate = self;
        
        let dbServiceInstance = dbService()
        
        if(dbServiceInstance.getLoginData().username != ""){
            _ = firstly{
                dbServiceInstance.getData()
                }.then{result -> Void in
                    self.performSegue(withIdentifier: "alreadyRegisterChangeToDevice", sender: nil)
            }
        }
        
        //Some Visuall Tweaks
        self.view.layer.insertSublayer(colorServiceInstance.backgroundGradientColor(self.view.bounds), at: 0)
        self.view.addSubview(colorServiceInstance.getStandardStatusbarColorView())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAsUser(_ sender: AnyObject) {
        let dbServiceInstance = dbService()
        let alertServiceInstance = AlertService()
        let username: String = usernameTextField.text!
        let password: String = passwordTextField.text!
        
        if(username == "" || password == ""){
            if(username == "" && password != ""){
                self.present(alertServiceInstance.getOkOnlyAlert("Empty username", message: "Please set a username"), animated: true, completion: nil)
            }
            if(password == "" && username != ""){
                self.present(alertServiceInstance.getOkOnlyAlert("Empty password", message: "Please set a password"), animated: true, completion: nil)
            }
            if(password == "" && username == ""){
                self.present(alertServiceInstance.getOkOnlyAlert("Empty username/password", message: "Please set a username and password"), animated: true, completion: nil)
            }
        }else{
            //_ = promise, is a hack to fix the warnings(Result of call to 'then(on:execute:)' is unused
            _ = dbServiceInstance.checkLoginData(username, password: password).then{result -> Void in
                
                if(result == "Authenticated"){
                    dbServiceInstance.setLoginData("\(username)", password: "\(password)", email: "")
                    
                    _ = firstly{
                        dbServiceInstance.getData()
                        }.then{result -> Void in
                            self.performSegue(withIdentifier: "alreadyRegisterChangeToDevice", sender: nil)
                    }
                }else{
                    self.present(alertServiceInstance.getOkOnlyAlert("Wrong password/username", message: "U have entered a wrong password or username"), animated: true, completion: nil)
                }
            }
            
        }
        
    }
    
    
    
    //UITextFieldReturn Keyboard Hide
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}

