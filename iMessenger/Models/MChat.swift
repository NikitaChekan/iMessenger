//
//  MChat.swift
//  iMessenger
//
//  Created by jopootrivatel on 16.04.2023.
//

import UIKit

struct MChat: Hashable, Decodable {
    var friendUserName: String
    var friendAvatarStringURL: String
    var lastMessageContent: String
    var friendId: String
    
    var representation: [String : Any] {
        var rep = ["friendUserName": friendUserName]
        rep = ["friendAvatarStringURL": friendAvatarStringURL]
        rep = ["friendId": friendId]
        rep = ["lastMessage": lastMessageContent]
        return rep
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(friendId)
    }
    
    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.friendId == rhs.friendId
    }
}
