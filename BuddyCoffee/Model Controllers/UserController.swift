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
    var buddyUser: BuddyUser?
    let db = Firestore.firestore()
    
    func createBuddyUser(user: User) {
        db.collection("users").document(user.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                guard let pointData = document.data()?["points"], let points = pointData as? Int else { return }
                self.buddyUser = BuddyUser(id: user.uid, points: points)
            }
        }
    }
}
