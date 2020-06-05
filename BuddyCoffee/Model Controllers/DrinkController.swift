//
//  DrinkController.swift
//  BuddyCoffee
//
//  Created by Uy Cung Dinh on 7/3/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import Foundation
import Firebase

class DrinkController {
    
    static let shared = DrinkController()
    static let drinkUpdatedNotification = Notification.Name("DrinkController.drinkUpdated")
    static let orderUpdatedNotification = Notification.Name("DrinkController.orderUpdated")
    
    private var categories: [String] = []
    var getCategories: [String] {
        return categories
    }
    private var drinks: [[Drink]] = []
    var getDrinks: [[Drink]] {
        return drinks
    }
    private var drinksById: [String: Drink] = [:]
    var order = Order() {
        didSet {
            NotificationCenter.default.post(name: DrinkController.orderUpdatedNotification, object: nil)
        }
    }
    var orderHistoryIds: [String] = []
    
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    
    func drink(withId id: String) -> Drink? {
        return drinksById[id]
    }
    
    func loadRemoteData() {
        var categoryDictionary: [String: Int] = [:]
        var count = 0
        db.collection("drinks").getDocuments { (querySnapshot, err) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    let id = document.documentID
                    guard let nameData = document.data()["name"], let name = nameData as? String else { continue }
                    guard let descriptionData = document.data()["description"], let description = descriptionData as? String else { continue }
                    guard let priceData = document.data()["price"], let price = priceData as? Int else { continue }
                    guard let categoryData = document.data()["category"], let category = categoryData as? String else { continue }
                    let drink = Drink(id: id, name: name, category: category, price: price, description: description)
                    if categoryDictionary[category] == nil {
                        categoryDictionary[category] = count
                        self.categories.append(category)
                        self.drinks.append([])
                        count += 1
                    }
                    self.drinks[categoryDictionary[category]!].append(drink)
                    self.drinksById[id] = drink
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: DrinkController.drinkUpdatedNotification, object: nil)
                    }
                }
            }
        }
    }
    
    func fetchDrinkImage(drinkName: String, completion: @escaping (UIImage?) -> Void) {
        let imgRef = storageRef.child("drink_images/\(drinkName).jpg")
        imgRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let data = data {
                let image = UIImage(data: data)
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
    
    func submitOrder(email: String, name: String, phone: String, address: String, total: Int, completion: @escaping (Error?) -> Void) {
        order.setDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        let dateString = dateFormatter.string(from: order.date)
        
       var drinkDataArray: [[String: Any]] = []
        for drink in order.drinks {
            var drinkData: [String: Any] = [:]
            drinkData["name"] = drink.drink.name
            drinkData["price"] = drink.drink.price
            drinkData["description"] = drink.drink.description
            drinkData["quantity"] = drink.quantity
            drinkDataArray.append(drinkData)
        }
        let data: [String: Any] = [
            "email": email,
            "name": name,
            "phone": phone,
            "address": address,
            "date": dateString,
            "drinks": drinkDataArray,
            "total": total
        ]
        if let buddyUser = UserController.shared.buddyUser {
            db.collection("users").document(buddyUser.id).collection("order-history").document(dateString).setData(data) { err in
                if let err = err {
                    completion(err)
                } else {
                    completion(nil)
                }
            }
        } else {
            var ref: DocumentReference? = nil
            ref = db.collection("orders").addDocument(data: data) { err in
                if let err = err {
                    completion(err)
                } else {
                    self.orderHistoryIds.append(ref!.documentID)
                    completion(nil)
                }
            }
        }
    }
    
    func encodeCart() {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let cartFileURL = documentsDirectoryURL.appendingPathComponent("cart").appendingPathExtension("json")
        if let data = try? JSONEncoder().encode(order) {
            try? data.write(to: cartFileURL)
        }
    }
    
    func decodeCart() {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let cartFileURL = documentsDirectoryURL.appendingPathComponent("cart").appendingPathExtension("json")
        if let data = try? Data(contentsOf: cartFileURL) {
            order = (try? JSONDecoder().decode(Order.self, from: data)) ?? Order(drinks: [])
        }
    }
    
    func encodeOrderHistoryIds() {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let orderHistoryIdsURL = documentsDirectoryURL.appendingPathComponent("orderHistoryIds").appendingPathExtension("json")
        if let data = try? JSONEncoder().encode(orderHistoryIds) {
            try? data.write(to: orderHistoryIdsURL)
        }
    }
    
    func decodeOrderHistoryIds() {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let orderHistoryIdsURL = documentsDirectoryURL.appendingPathComponent("orderHistoryIds").appendingPathExtension("json")
        if let data = try? Data(contentsOf: orderHistoryIdsURL) {
            orderHistoryIds = (try? JSONDecoder().decode(Array<String>.self, from: data)) ?? [String]()
        }
    }
    
    func fetchOrderHistory(completion: @escaping (OrderHistory?) -> Void) {
        guard !orderHistoryIds.isEmpty else { return }
        var orderHistory = OrderHistory(orders: [])
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy 'at' HH:mm:ss"
        
        for orderId in orderHistoryIds {
            db.collection("orders").document(orderId).getDocument { snapshot, error in
                if let snapshot = snapshot {
                    let data: [String: Any] = snapshot.data()!
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
                } else {
                    completion(nil)
                }
            }
        }
    }

}
