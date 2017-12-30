//
//  colorService.swift
//  IntelliPlug Assistant
//
//  Created by tobias lüscher on 29.08.16.
//  Copyright © 2016 IntelliPlug. All rights reserved.
//

import UIKit

class colorService: NSObject {
    
    func getStandardStatusbarColorView() -> UIView{
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0)
        return blurEffectView
    }
    
    func backgroundGradientColor(_ bounds: CGRect) -> CAGradientLayer{
        let colorTop = UIColor(red: 179.0/255.0, green: 248.0/255.0, blue: 152.0/255.0, alpha: 1.0).cgColor
        let colorMiddle = UIColor(red: 107.0/255.0, green: 224.0/255.0, blue: 177.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 47.0/255.0, green: 131.0/255.0, blue: 117.0/255.0, alpha: 1.0).cgColor

        let gl: CAGradientLayer
        gl = CAGradientLayer()
        gl.frame = bounds
        gl.colors = [ colorTop, colorMiddle, colorBottom]
        gl.locations = [ 0.0, 0.5, 1.0]
        
        return gl
    }

}
