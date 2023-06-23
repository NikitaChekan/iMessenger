//
//  MMessage.swift
//  iMessenger
//
//  Created by jopootrivatel on 01.05.2023.
//

import UIKit
import FirebaseFirestore
import MessageKit

struct MMessage: Hashable, MessageType {
    
    // MARK: - Properties
    let content: String
    var sender: MessageKit.SenderType
    var sentDate: Date
    let id: String?
    var isViewed: Bool
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    
    var kind: MessageKit.MessageKind {
        if let image = image {
            let mediaItem = ImageItem(url: nil, image: nil, placeholderImage: image, size: image.size)
            return .photo(mediaItem)
        } else {
            return .text(content)
        }
    }
    
    var image: UIImage? = nil
    var downloadURL: URL? = nil
    
    // MARK: - Init
    init(user: MUser, content: String, isViewed: Bool) {
        self.content = content
        sender = MSender(senderId: user.id, displayName: user.userName)
        sentDate = Date()
        id = nil
        self.isViewed = isViewed
    }
    
    init(user: MUser, image: UIImage, isViewed: Bool) {
        sender = MSender(senderId: user.id, displayName: user.userName)
        self.image = image
        content = ""
        sentDate = Date()
        id = nil
        self.isViewed = isViewed
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let sendDate = data["created"] as? Timestamp else { return nil }
        guard let senderId = data["senderId"] as? String else { return nil }
        guard let senderName = data["senderName"] as? String else { return nil }
        guard let isViewed = data["isViewed"] as? Bool else { return nil }
        

        self.id = document.documentID
        self.sentDate = sendDate.dateValue()
        self.sender = MSender(senderId: senderId, displayName: senderName)
        self.isViewed = isViewed
        
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            self.content = ""
        } else {
            return nil
        }

    }
    
    var representation: [String : Any] {
        var rep: [String : Any] = [
            "created" : sentDate,
            "senderId" : sender.senderId,
            "senderName" : sender.displayName,
            "isViewed" : isViewed
        ]
        
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        
        return rep
    }
    
    // MARK: - Methods
    func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
    }
    
    static func == (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
}
// MARK: - Comparable
extension MMessage: Comparable {
    static func < (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}
