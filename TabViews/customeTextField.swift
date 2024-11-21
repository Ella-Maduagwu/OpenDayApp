//
//  customeTextField.swift
//  OpenDayApp
//
//  Created by Emmanuella Maduagwu on 09/11/2024.
//

import UIKit

class customeTextField: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
            layer.backgroundColor = UIColor(red: 249/255, green: 250/255, blue: 250/255, alpha: 1).cgColor
        layer.cornerRadius = 15
            
        }
    }



