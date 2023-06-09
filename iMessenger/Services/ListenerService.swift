//
//  ListenerService.swift
//  iMessenger
//
//  Created by jopootrivatel on 30.04.2023.
//

import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

final class ListenerService {
    
    static let shared = ListenerService()
    
    private let db = Firestore.firestore()
    
    private var usersReference: CollectionReference {
        return db.collection("users")
    }
    
    private var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }
    
    // MARK: - Methods
    func usersObserve(users: [MUser], completion: @escaping (Result<[MUser], Error>) -> Void) -> ListenerRegistration? {
        var users = users
        let usersListener = usersReference.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { diff in
                guard let mUser = MUser(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    guard !users.contains(mUser) else { return }
                    guard mUser.id != self.currentUserId else { return }
                    users.append(mUser)
                case .modified:
                    guard let index = users.firstIndex(of: mUser) else { return }
                    users[index] = mUser
                case .removed:
                    guard let index = users.firstIndex(of: mUser) else { return }
                    users.remove(at: index)
                }
            }
            completion(.success(users))
        }
        return usersListener
    }
    
    func waitingChatsObserve(chats: [MChat], addedCompletion:((MChat) -> Void)? = nil, completion: @escaping (Result<[MChat], Error>) -> Void) -> ListenerRegistration? {
        
        var chats = chats
        
        let chatsReference = db.collection(["users", currentUserId, "waitingChats"].joined(separator: "/"))
        let chatsListener = chatsReference.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { diff in
                guard let chat = MChat(document: diff.document) else { return }
                
                switch diff.type {
                case .added:
                    guard !chats.contains(chat) else { return }
                    chats.append(chat)
                    addedCompletion?(chat)
                case .modified:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats[index] = chat
                case .removed:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats.remove(at: index)
                }
            }
            
            completion(.success(chats))
        }
        
        return chatsListener
    }
    
    func activeChatsObserve(chats: [MChat], modifiedCompletion: ((Bool, MChat) -> Void)? = nil, completion: @escaping (Result<[MChat], Error>) -> Void) -> ListenerRegistration? {
        
        var chats = chats
        
        let chatsReference = db.collection(["users", currentUserId, "activeChats"].joined(separator: "/"))
        let chatsListener = chatsReference.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { diff in
                guard let chat = MChat(document: diff.document) else { return }
                
                switch diff.type {
                case .added:
                    guard !chats.contains(chat) else { return }
                    chats.append(chat)
                case .modified:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats[index] = chat
                    modifiedCompletion?(chat.lastSenderId != self.currentUserId, chat)
                case .removed:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats.remove(at: index)
                }
            }
            
            completion(.success(chats))
        }
        
        return chatsListener
    }
    
    func messagesObserve(chat: MChat, completion: @escaping (Result<MMessage, Error>) -> Void) -> ListenerRegistration? {
        
        let reference = usersReference.document(currentUserId).collection("activeChats").document(chat.friendId).collection("messages")
        
        let messagesListener = reference.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { diff in
                guard let message = MMessage(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    completion(.success(message))
                case .modified:
                    break
                case .removed:
                    break
                }
            }
        }
        return messagesListener
    }

}
