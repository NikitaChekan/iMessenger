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
    
    func getUserData(user: User, completion: @escaping (Result<MUser, Error>) -> Void) {
        let docRef = usersRef.document(user.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let mUser = MUser(document: document) else {
                    completion(.failure(UserError.cannotUnwrapToUser))
                    return
                }
                completion(.success(mUser))
            } else {
                completion(.failure(UserError.cannotGetUserInfo))
            }
        }
    }
    
    func saveProfileWith(id: String, email: String, userName: String?, avatarImageString: String?, description: String?, sex: String?, completion: @escaping (Result<MUser, Error>) -> Void) {
        
        guard Validators.isFilled(userName: userName, description: description, sex: sex) else {
            completion(.failure(UserError.NotFilled))
            return
        }
        
        let mUser = MUser(
            userName: userName!,
            email: email,
            avatarStringURL: "not exist",
            description: description!,
            sex: sex!,
            id: id
        )
        
        self.usersRef.document(mUser.id).setData(mUser.representation) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(mUser))
            }
        }
    }
}
