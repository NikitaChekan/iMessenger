//
//  MUser.swift
//  iMessenger
//
//  Created by jopootrivatel on 16.04.2023.
//

import UIKit

struct MUser: Hashable, Decodable {
    var userName: String
    var email: String
    var avatarStringURL: String
    var description: String
    var sex: String
    var id: String
    
    var representation: [String: Any] {
        var rep = ["userName": userName]
        rep = ["email": email]
        rep = ["avatarStringURL": avatarStringURL]
        rep = ["description": description]
        rep = ["sex": sex]
        rep = ["uid": id]
        return rep
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MUser, rhs: MUser) -> Bool {
        return lhs.id == rhs.id
    }
    
    func contains(filter: String?) -> Bool {
        guard let filter = filter else { return true }
        if filter.isEmpty { return true }
        let lowercasedFilter = filter.lowercased()
        return userName.lowercased().contains(lowercasedFilter)
    }
}
