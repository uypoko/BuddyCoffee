//
//  UserController.swift
//  BuddyCoffee
//
//  Created by Uy Cung Dinh on 7/3/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import Foundation
import Firebase

class UserController {
    
    static let shared = UserController()
    var buddyUser: BuddyUser? {
        didSet {
            NotificationCenter.default.post(name: UserController.authChangedNotification, object: nil)
        }
    }
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    static let authChangedNotification = Notification.Name("UserController.authChanged")
    var handle: AuthStateDidChangeListenerHandle?
    
    func fetchBuddyUser() {
        // Listen for authentication state
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.db.collection("users").document(user.uid).getDocument { (document, error) in
                    if let document = document, document.exists {
                        guard let emailData = document.data()?["email"], let email = emailData as? String else { return }
                        let name = user.displayName
                        var phone: Int?
                        if let phoneData = document.data()?["phone"] { phone = phoneData as? Int }
                        var address: String?
                        if let addressData = document.data()?["address"] { address = addressData as? String }
                        guard let pointData = document.data()?["points"], let points = pointData as? Int else { return }
                        if phone != nil && address != nil {
                            self.buddyUser = BuddyUser(id: user.uid, email: email, name: name!, phone: phone!, address: address!, points: points)
                        } else {
                            self.buddyUser = BuddyUser(id: user.uid, email: email, name: name!, points: points)
                        }
                    }
                }
            } else {
                UserController.shared.buddyUser = nil
            }
        }
    }
    
    func fetchUserImage(completion: @escaping (UIImage?) -> Void) {
        guard let buddyUser = buddyUser else { return }
        let imgRef = storageRef.child("users/\(buddyUser.id)/avatar.jpg")
        imgRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let data = data {
                let image = UIImage(data: data)
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
    }
    
    func uploadProfilePicture() {
        
    }
}
