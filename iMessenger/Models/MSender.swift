//
//  MSender.swift
//  iMessenger
//
//  Created by jopootrivatel on 08.05.2023.
//

import UIKit
import MessageKit

class MSender: SenderType {
    
    var senderId: String
    var displayName: String
    
    init(senderId: String, displayName: String) {
        self.senderId = senderId
        self.displayName = displayName
    }
}
