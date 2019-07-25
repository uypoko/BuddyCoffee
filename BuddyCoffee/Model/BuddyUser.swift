//
//  BuddyUser.swift
//  BuddyCoffee
//
//  Created by Uy Cung Dinh on 7/3/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import Foundation

class BuddyUser {
    let id: String
    var email: String
    var name: String
    var phone: String
    var address: String
    var points: Int
    var membershipStatus: String {
        var status = "\(points) ⭑ "
        switch points {
        case 0..<100:
            status += "New Member"
        case 100..<200:
            status += "Gold Member"
        case 200...:
            status += "Diamond Member"
        default:
            status = ""
        }
        return status
    }
    
    init(id: String, email: String, name: String, phone: String, address: String, points: Int) {
        self.id = id
        self.email = email
        self.name = name
        self.phone = phone
        self.address = address
        self.points = points
    }
}
