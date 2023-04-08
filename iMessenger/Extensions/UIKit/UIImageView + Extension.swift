//
//  UIImageView + Exyension.swift
//  iMessenger
//
//  Created by jopootrivatel on 08.04.2023.
//

import UIKit

extension UIImageView {
    
    convenience init(image: UIImage?, contentMode: UIView.ContentMode) {
        self.init()
        
        self.image = image
        self.contentMode = contentMode
    }
}
