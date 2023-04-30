//
//  MMessage.swift
//  iMessenger
//
//  Created by jopootrivatel on 01.05.2023.
//

import UIKit

struct MMessage: Hashable {
    let content: String
    let senderId: String
    let senderUserName: String
    var sendDate: Data
    let id: String?
    
    init(user: MUser, content: String) {
        self.content = content
        senderId = user.id
        senderUserName = user.userName
        sendDate = Data()
        id = nil
    }
    
    var representation: [String : Any] {
        let rep: [String : Any] = [
            "created" : sendDate,
            "senderId" : senderId,
            "senderName" : senderUserName,
            "content" : content
        ]
        
        return rep
    }
    
}
