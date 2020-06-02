//
//  CartTableViewController.swift
//  BuddyCoffee
//
//  Created by Uy Cung Dinh on 7/3/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit

class CartTableViewController: UITableViewController {

    var total: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        NotificationCenter.default.addObserver(tableView!, selector: #selector(UITableView.reloadData), name: DrinkController.orderUpdatedNotification, object: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return DrinkController.shared.order.drinks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "drinkCell", for: indexPath) as! DrinkTableViewCell
        let drinkInOrder = DrinkController.shared.order.drinks[indexPath.row]
        // Configure the cell...
        cell.updateUI(withDrink: drinkInOrder)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    // MARK: Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            DrinkController.shared.order.drinks.remove(at: indexPath.row)
        }
    }

    @IBAction func confirmCartButtonTapped(_ sender: Any) {
        guard !DrinkController.shared.order.drinks.isEmpty else { return }
        performSegue(withIdentifier: "DeliveryAddressSegue", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !DrinkController.shared.order.drinks.isEmpty {
            total = DrinkController.shared.order.drinks.reduce(0) { (result, drinkInOrder) -> Int in
                return result + (drinkInOrder.drink.price * drinkInOrder.quantity)
            }
            self.navigationItem.title = "Total: \(total) đ"
        } else {
            navigationItem.title = "Cart"
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "DeliveryAddressSegue" {
            let deliveryAddressViewController = segue.destination as! DeliveryAddressViewController
            deliveryAddressViewController.orderTotal = total
        }
    }
    
    @IBAction func unwindToCartTableViewController(segue: UIStoryboardSegue) {
        DrinkController.shared.order.drinks.removeAll()
        total = 0
    }
}
