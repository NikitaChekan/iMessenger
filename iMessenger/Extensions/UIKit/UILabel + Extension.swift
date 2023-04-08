//
//  UILabel + Extension.swift
//  iMessenger
//
//  Created by jopootrivatel on 08.04.2023.
//

import UIKit

extension UILabel {
    
    convenience init (text: String, font: UIFont? = .avenir20()) {
        self.init()
        
        self.text = text
        self.font = font
    }
    
}
