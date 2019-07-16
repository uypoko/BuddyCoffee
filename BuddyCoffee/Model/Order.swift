//
//  Order.swift
//  BuddyCoffee
//
//  Created by Ryan on 7/3/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import Foundation

struct Order: Codable, Equatable, Comparable {
    
    var drinks: [DrinkInOrder]
    var date: Date
    
    init(drinks: [DrinkInOrder] = []) {
        self.drinks = drinks
        date = Date()
    }
    
    init(drinks: [DrinkInOrder], date: Date) {
        self.drinks = drinks
        self.date = date
    }
    
    mutating func setDate() {
        date = Date()
    }
    
    static func ==(lhs: Order, rhs: Order) -> Bool {
        return lhs.date == rhs.date
    }
    
    static func <(lhs: Order, rhs: Order) -> Bool {
        return lhs.date < rhs.date
    }
}
