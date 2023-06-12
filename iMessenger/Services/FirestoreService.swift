//
//  FirestoreService.swift
//  iMessenger
//
//  Created by jopootrivatel on 20.04.2023.
//

import Firebase
import FirebaseFirestore

class FirestoreService {
    
    static let shared = FirestoreService()

    let db = Firestore.firestore()
    
    private var usersRef: CollectionReference {
        return db.collection("users")
    }
    
    private var waitingChatsReference: CollectionReference {
        return db.collection(["users", currentUser.id, "waitingChats"].joined(separator: "/"))
    }
    
    private var activeChatsReference: CollectionReference {
        return db.collection(["users", currentUser.id, "activeChats"].joined(separator: "/"))
    }
    
    var currentUser: MUser!
    
    func getUserData(user: User, completion: @escaping (Result<MUser, Error>) -> Void) {
        let docRef = usersRef.document(user.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let mUser = MUser(document: document) else {
                    completion(.failure(UserError.cannotUnwrapToUser))
                    return
                }
                self.currentUser = mUser
                completion(.success(mUser))
            } else {
                completion(.failure(UserError.cannotGetUserInfo))
            }
        }
    }
    
    func saveProfileWith(id: String, email: String, userName: String?, avatarImage: UIImage?, description: String?, sex: String?, completion: @escaping (Result<MUser, Error>) -> Void) {
        
        guard Validators.isFilled(userName: userName, description: description, sex: sex) else {
            completion(.failure(UserError.NotFilled))
            return
        }
        
        guard avatarImage != UIImage(named: "avatar") else {
            completion(.failure(UserError.photoNotExist))
            return
        }
        
        var mUser = MUser(
            userName: userName!,
            email: email,
            avatarStringURL: "not exist",
            description: description!,
            sex: sex!,
            id: id
        )
        
        StorageService.shared.upload(photo: avatarImage!) { result in
            switch result {
            case .success(let url):
                mUser.avatarStringURL = url.absoluteString
                
                self.usersRef.document(mUser.id).setData(mUser.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(mUser))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        } // StorageService
    } // saveProfileWith
    
    func createWaitingChat(message: String, receiver: MUser, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = db.collection(["users", receiver.id, "waitingChats"].joined(separator: "/"))
        let messageRef = reference.document(self.currentUser.id).collection("messages")
        
        let message = MMessage(user: currentUser, content: message, isViewed: false)
        let chat = MChat(
            friendUserName: currentUser.userName,
            friendAvatarStringURL: currentUser.avatarStringURL,
            friendId: currentUser.id,
            lastMessageContent: message.content,
            lastSenderId: currentUser.id,
            lastMessageDate: message.sentDate
        )
        
        reference.document(currentUser.id).setData(chat.representation) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            messageRef.addDocument(data: message.representation) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(Void()))
            }
        }
    }
    
    func deleteWaitingChat(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        waitingChatsReference.document(chat.friendId).delete { error in
            if let error = error {
                completion(.failure(error))
            }
            
            completion(.success(Void()))
            self.deleteMessages(chat: chat, completion: completion)
        }
    }
    
    func deleteMessages(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = waitingChatsReference.document(chat.friendId).collection("messages")
        
        getWaitingChatMessages(chat: chat) { result in
            switch result {
            case .success(let messages):
                for message in messages {
                    guard let documentId = message.id else { return }
                    let messageReference = reference.document(documentId)
                    messageReference.delete { error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        completion(.success(Void()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getWaitingChatMessages(chat: MChat, completion: @escaping (Result<[MMessage], Error>) -> Void) {
        let reference = waitingChatsReference.document(chat.friendId).collection("messages")
        
        var messages = [MMessage]()
        
        reference.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            for document in querySnapshot!.documents {
                guard let message = MMessage(document: document) else { return }
                messages.append(message)
            }
            
            completion(.success(messages))
        }
    }
    
    func changeToActive(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        getWaitingChatMessages(chat: chat) { result in
            switch result {
            case .success(let messages):
                self.deleteWaitingChat(chat: chat) { result in
                    switch result {
                    case .success:
                        self.createActiveChat(chat: chat, messages: messages) { result in
                            switch result {
                            case .success:
                                completion(.success(Void()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createActiveChat(chat: MChat, messages: [MMessage], completion: @escaping (Result<Void, Error>) -> Void) {
        
        let messageReference = activeChatsReference.document(chat.friendId).collection("messages")
        
        activeChatsReference.document(chat.friendId).setData(chat.representation) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            for message in messages {
                messageReference.addDocument(data: message.representation) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(Void()))
                }
            }
        }
    }
    
    func sendMessage(chat: MChat, message: MMessage, isImage: Bool = false, completion: @escaping (Result<Void, Error>) -> Void) {
        let friendReference = usersRef.document(chat.friendId).collection("activeChats").document(currentUser.id)
        let friendMessageReference = friendReference.collection("messages")
        let myReference = usersRef.document(currentUser.id).collection("activeChats").document(chat.friendId)
        let myMessageReference = myReference.collection("messages")
        
        let messageContent = isImage ? "Изображение 🖼" : message.content
        
        // Update chat for current user
        var chat = chat
        chat.lastMessageContent = messageContent
        chat.lastSenderId = self.currentUser.id
        chat.lastMessageDate = message.sentDate
        
        // Create chat for friend
        let chatForFriend = MChat(
            friendUserName: currentUser.userName,
            friendAvatarStringURL: currentUser.avatarStringURL,
            friendId: currentUser.id,
            lastMessageContent: message.content,
            lastSenderId: currentUser.id,
            lastMessageDate: message.sentDate
        )
        
        friendReference.setData(chatForFriend.representation) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            friendMessageReference.addDocument(data: message.representation) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                myReference.setData(chat.representation) { error in
                    if let error = error {
                        completion(.failure(error))
                    }
                    myMessageReference.addDocument(data: message.representation) { error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        completion(.success(Void()))
                    }
                }
            }
        }
    }
    
    func checkExistenceWaitingChat(for user: MUser, completion: @escaping (Result<Bool, Error>) -> Void) {
        let friendReference = usersRef.document(user.id).collection("waitingChats").document(currentUser.id)
        
        friendReference.getDocument { document, error in
            if let document = document, document.exists {
                guard let _ = MChat(document: document) else { return }
                completion(.success(true))
            }
            
            if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    func checkExistenceActiveChat(for user: MUser, completion: @escaping (Result<Bool, Error>) -> Void) {
        let userReference = usersRef.document(currentUser.id).collection("activeChats").document(user.id)
        
        userReference.getDocument { document, error in
            if let document = document, document.exists {
                guard let _ = MChat(document: document) else { return }
                
                completion(.success(true))
            }
            
            if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    func updateViewedMessage(for senderId: String, friendId: String) {
        let messageReference = usersRef.document(currentUser.id).collection("activeChats").document(friendId).collection("messages").document(senderId)
        
        messageReference.updateData([
            "isViewed": true
        ])
    }
    
    func getChat(for id: String, completion: @escaping (Result<MChat, Error>) -> Void) {
            let chatReference = usersRef.document(currentUser.id).collection("activeChats").document(id)
            
            chatReference.getDocument { document, error in
                if let document = document, document.exists {
                    guard let chat = MChat(document: document) else { return }
                    
                    completion(.success(chat))
                }
                
                if let error = error {
                    completion(.failure(error))
                }
            }
        }
    
}
