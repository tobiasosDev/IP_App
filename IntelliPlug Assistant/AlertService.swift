//
//  AlertService.swift
//  IntelliPlug Assistant
//
//  Created by tobias lüscher on 06.09.16.
//  Copyright © 2016 IntelliPlug. All rights reserved.
//

import UIKit

class AlertService: NSObject {

    func getOkOnlyAlert(_ title: String, message: String) -> UIAlertController{
        // create the alert
        let alert = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        return alert
    }
    
    func getTextFieldFuncAlert(_ alertTitle: String, alertMessage: String, textFieldPlaceHolder placeholder: String, funct: @escaping (UITextField) -> Void) -> UIAlertController{
        //1. Create the alert controller.
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        //2. Add the text field.
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = placeholder
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            funct(textField)
            
        }))
        
        //Cancel handler/Button
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        return alert
    }
}
