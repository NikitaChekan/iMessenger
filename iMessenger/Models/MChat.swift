//
//  MChat.swift
//  iMessenger
//
//  Created by jopootrivatel on 16.04.2023.
//

import UIKit
import FirebaseFirestore

struct MChat: Hashable, Decodable {
    
    static let waitingPlugModel = MChat(friendUserName: "nil", friendAvatarStringURL: "0", friendId: "0", lastMessageContent: "nil", lastSenderId: "0", lastMessageDate: Date())
    static let activePlugModel = MChat(friendUserName: "nil", friendAvatarStringURL: "1", friendId: "1", lastMessageContent: "nil", lastSenderId: "1", lastMessageDate: Date())
    
    var friendUserName: String
    var friendAvatarStringURL: String
    var lastMessageContent: String
    var lastMessageDate: Date
    var lastSenderId: String
    var friendId: String
    
    var representation: [String : Any] {
        var rep: [String : Any] = ["friendUserName": friendUserName]
        rep["friendAvatarStringURL"] = friendAvatarStringURL
        rep["friendId"] = friendId
        rep["lastMessage"] = lastMessageContent
        rep["lastSenderId"] = lastSenderId
        rep["lastMessageDate"] = lastMessageDate
        return rep
    }
    
    init(friendUserName: String, friendAvatarStringURL: String, friendId: String, lastMessageContent: String, lastSenderId: String, lastMessageDate: Date) {
        self.friendUserName = friendUserName
        self.friendAvatarStringURL = friendAvatarStringURL
        self.friendId = friendId
        self.lastMessageContent = lastMessageContent
        self.lastSenderId = lastSenderId
        self.lastMessageDate = lastMessageDate
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        guard let friendUserName = data["friendUserName"] as? String,
              let friendAvatarStringURL = data["friendAvatarStringURL"] as? String,
              let friendId = data["friendId"] as? String,
              let lastMessageContent = data["lastMessage"] as? String,
              let lastMessageDate = data["lastMessageDate"] as? Timestamp,
              let lastSenderId = data["lastSenderId"] as? String else { return nil }
        
        self.friendUserName = friendUserName
        self.friendAvatarStringURL = friendAvatarStringURL
        self.friendId = friendId
        self.lastMessageContent = lastMessageContent
        self.lastMessageDate = lastMessageDate.dateValue()
        self.lastSenderId = lastSenderId
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let friendUserName = data["friendUserName"] as? String,
              let friendAvatarStringURL = data["friendAvatarStringURL"] as? String,
              let friendId = data["friendId"] as? String,
              let lastMessageContent = data["lastMessage"] as? String,
              let lastSenderId = data["lastSenderId"] as? String,
              let lastMessageDate = data["lastMessageDate"] as? Timestamp else { return nil }
        
        self.friendUserName = friendUserName
        self.friendAvatarStringURL = friendAvatarStringURL
        self.friendId = friendId
        self.lastMessageContent = lastMessageContent
        self.lastSenderId = lastSenderId
        self.lastMessageDate = lastMessageDate.dateValue()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(friendId)
    }
    
    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.friendId == rhs.friendId
    }
    
    func contains(filter: String?) -> Bool {
        guard let filter = filter else { return true }
        
        if filter.isEmpty {
            return true
        }
        
        let lowercasedFilter = filter.lowercased()
        return friendUserName.lowercased().contains(lowercasedFilter)
    }
}
