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
    
    func addAuthStateListener() {
        // Listen for authentication state
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.db.collection("users").document(user.uid).getDocument { (document, error) in
                    if let document = document, document.exists {
                        guard let emailData = document.data()?["email"], let email = emailData as? String else { return }
                        guard let nameData = document.data()?["name"], let name = nameData as? String else { return }
                        guard let phoneData = document.data()?["phone"], let phone = phoneData as? Int else { return }
                        guard let addressData = document.data()?["address"], let address = addressData as? String else { return }
                        var points = 0 // The server takes a while to create this field in the database after a registration
                        if let pointData = document.data()?["points"] { points = pointData as! Int }
                        self.buddyUser = BuddyUser(id: user.uid, email: email, name: name, phone: phone, address: address, points: points)
                    }
                }
            } else {
                self.buddyUser = nil
            }
        }
    }
    
    func removeAuthStateListener() {
        Auth.auth().removeStateDidChangeListener(handle!)
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
    
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authData, error) in
            if error == nil {
                completion(nil)
            } else {
                completion(error)
            }
        }
    }
    
    func signUp(email: String, password: String, name: String, phone: Int, address: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authData, error in
            if let user = authData?.user, error == nil {
                let data: [String: Any] = [
                    "name": name,
                    "phone": phone,
                    "address": address
                ]
                print(user.uid)
                self.db.collection("users").document(user.uid).setData(data, merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        completion(nil)
                    }
                }
            } else {
                completion(error)
            }
        }
    }
    
    func updateInformation(name: String, phone: Int, address: String, completion: @escaping (Error?) -> Void) {
        guard let user = buddyUser else { return }
        db.collection("users").document(user.id).setData([
            "name": name,
            "phone": phone,
            "address": address
        ], merge: true) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func reloadUserInformation() {
        guard let user = buddyUser else { return }
        db.collection("users").document(user.id).getDocument { (document, error) in
            if let document = document, document.exists {
                guard let emailData = document.data()?["email"], let email = emailData as? String else { return }
                guard let nameData = document.data()?["name"], let name = nameData as? String else { return }
                guard let phoneData = document.data()?["phone"], let phone = phoneData as? Int else { return }
                guard let addressData = document.data()?["address"], let address = addressData as? String else { return }
                guard let pointsData = document.data()?["points"], let points = pointsData as? Int else { return }
                self.buddyUser = BuddyUser(id: user.id, email: email, name: name, phone: phone, address: address, points: points)
            }
        }
    }
    
    func updatePassword(currentPassword: String ,newPassword: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: user.email!, password: currentPassword)
        
        user.reauthenticate(with: credential) { authData, error in
            if let error = error {
                completion(error)
            } else {
                user.updatePassword(to: newPassword) { error in
                    if let error = error {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func fetchOrderHistory(completion: @escaping (OrderHistory?) -> Void) {
        guard let user = buddyUser else { return }
        var orderHistory = OrderHistory(orders: [])
        db.collection("users").document(user.id).collection("order-history").getDocuments { snapshot, error in
            if let snapshot = snapshot {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy 'at' h:mm:ss a"
                for document in snapshot.documents {
                    let data: [String: Any] = document.data()
                    guard let dateData = data["date"], let dateString = dateData as? String else { return }
                    guard let date = dateFormatter.date(from: dateString) else { return }
                    guard let drinksData = data["drinks"] as? [[String: Any]] else { return }
                    var drinks: [DrinkInOrder] = []
                    var id = 0
                    for drink in drinksData {
                        let name = drink["name"] as! String
                        let price = drink["price"] as! Int
                        let description = drink["description"] as! String
                        let quantity = drink["quantity"] as! Int
                        let drink = Drink(id: "\(id += 1)", name: name, category: "", price: price, description: description)
                        let drinkInOrder = DrinkInOrder(drink: drink, quantity: quantity)
                        drinks.append(drinkInOrder)
                    }
                    let order = Order(drinks: drinks, date: date)
                    orderHistory.orders.append(order)
                    completion(orderHistory)
                }
            } else {
                completion(nil)
            }
        }
    }
    
}
