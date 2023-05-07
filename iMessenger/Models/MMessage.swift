//
//  MMessage.swift
//  iMessenger
//
//  Created by jopootrivatel on 01.05.2023.
//

import UIKit
import FirebaseFirestore

struct MMessage: Hashable {
    let content: String
    let senderId: String
    let senderUserName: String
    var sendDate: Date
    let id: String?
    
    init(user: MUser, content: String) {
        self.content = content
        senderId = user.id
        senderUserName = user.userName
        sendDate = Date()
        id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let sendDate = data["created"] as? Timestamp else { return nil }
        guard let senderId = data["senderId"] as? String else { return nil }
        guard let senderName = data["senderName"] as? String else { return nil }
        guard let content = data["content"] as? String else { return nil }

        self.id = document.documentID
        self.sendDate = sendDate.dateValue()
        self.senderId = senderId
        self.senderUserName = senderName
        self.content = content

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
