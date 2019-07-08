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
    
}
