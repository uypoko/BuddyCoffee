//
//  OrderHistory.swift
//  BuddyCoffee
//
//  Created by Ryan on 7/3/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import Foundation

struct OrderHistory {
    var orders: [Order]
    
    init(orders: [Order] = []) {
        self.orders = orders
    }
}
