//
//  OrderHistoryDetailTableViewController.swift
//  BuddyCoffee
//
//  Created by Ryan on 7/16/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit

class OrderHistoryDetailTableViewController: UITableViewController {

    var order: Order = Order(drinks: [])
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.title = "Order"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return order.drinks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "drinkCell", for: indexPath)
        let drinkInOrder = order.drinks[indexPath.row]
        // Configure the cell...
        cell.textLabel?.text = drinkInOrder.drink.name
        cell.detailTextLabel?.text = "\(drinkInOrder.quantity)x\(drinkInOrder.drink.price) đ"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
