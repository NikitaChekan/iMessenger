//
//  MUser.swift
//  iMessenger
//
//  Created by jopootrivatel on 16.04.2023.
//

import UIKit
import FirebaseFirestore

struct MUser: Hashable, Decodable {
    var userName: String
    var email: String
    var avatarStringURL: String
    var description: String
    var sex: String
    var id: String
    
    init(userName: String, email: String, avatarStringURL: String, description: String, sex: String, id: String) {
        self.userName = userName
        self.email = email
        self.avatarStringURL = avatarStringURL
        self.description = description
        self.sex = sex
        self.id = id
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        guard let userName = data["userName"] as? String,
        let email = data["email"] as? String,
        let avatarStringURL = data["avatarStringURL"] as? String,
        let description = data["description"] as? String,
        let sex = data["sex"] as? String,
        let id = data["uid"] as? String else { return nil }
        
        self.userName = userName
        self.email = email
        self.avatarStringURL = avatarStringURL
        self.description = description
        self.sex = sex
        self.id = id
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let userName = data["userName"] as? String,
              let email = data["email"] as? String,
              let avatarStringURL = data["avatarStringURL"] as? String,
              let description = data["description"] as? String,
              let sex = data["sex"] as? String,
              let id = data["uid"] as? String else { return nil }
        
        self.userName = userName
        self.email = email
        self.avatarStringURL = avatarStringURL
        self.description = description
        self.sex = sex
        self.id = id
    }
    
    var representation: [String: Any] {
        var rep = ["userName": userName]
        rep["email"] = email
        rep["avatarStringURL"] = avatarStringURL
        rep["description"] = description
        rep["sex"] = sex
        rep["uid"] =  id
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
