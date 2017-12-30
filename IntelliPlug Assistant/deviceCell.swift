//
//  deviceCell.swift
//  IntelliPlug Assistant
//
//  Created by tobias lüscher on 01.09.16.
//  Copyright © 2016 IntelliPlug. All rights reserved.
//

import UIKit

class deviceCell:  UITableViewCell{

    @IBOutlet weak var devicePicture: UIImageView!
    @IBOutlet weak var connectedDevices: UILabel!
    @IBOutlet weak var plugName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
