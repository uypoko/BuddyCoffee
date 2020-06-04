//
//  OrderHistoryTableViewController.swift
//  BuddyCoffee
//
//  Created by Ryan on 7/16/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit

class OrderHistoryTableViewController: UITableViewController {

    var orderHistory = OrderHistory(orders: [])
    var order: Order?
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.title = "Order History"
        if UserController.shared.buddyUser != nil {
            UserController.shared.fetchOrderHistory() { orderHistory in
                if let orderHistory = orderHistory {
                    self.orderHistory = orderHistory
                    self.tableView.reloadData()
                }
            }
        } else {
            DrinkController.shared.fetchOrderHistory() { orderHistory in
                if let orderHistory = orderHistory {
                    self.orderHistory = orderHistory
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return orderHistory.orders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath)
        let order = orderHistory.orders[indexPath.row]
        // Configure the cell...
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        let dateString = dateFormatter.string(from: order.date)
        cell.textLabel?.text = dateString
        let total = order.drinks.reduce(0) { (result, drinkInOrder) -> Int in
            return result + (drinkInOrder.drink.price * drinkInOrder.quantity)
        }
        cell.detailTextLabel?.text = "\(total) đ"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        order = orderHistory.orders[indexPath.row]
        performSegue(withIdentifier: "OrderDetailSegue", sender: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "OrderDetailSegue" {
            guard let order = order else { return }
            let orderDetailController = segue.destination as! OrderHistoryDetailTableViewController
            orderDetailController.order = order
        }
    }

}
