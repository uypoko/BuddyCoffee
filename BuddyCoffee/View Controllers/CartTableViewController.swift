//
//  CartTableViewController.swift
//  BuddyCoffee
//
//  Created by Uy Cung Dinh on 7/3/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit

class CartTableViewController: UITableViewController {

    var error: Error?
    
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

    @IBAction func submitButtonTapped(_ sender: Any) {
        guard !DrinkController.shared.order.drinks.isEmpty else { return }
        let orderTotal = DrinkController.shared.order.drinks.reduce(0) { (result, drinkInOrder) -> Int in
            return result + (drinkInOrder.drink.price * drinkInOrder.quantity)
        }
        let alert = UIAlertController(title: "Confirm Order", message: "You're about to submit the order with the total of \(orderTotal)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Submit", style: .default) { action in
            self.uploadOrder()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func uploadOrder() {
        DrinkController.shared.submitOrder { err in
            if let err = err {
                self.error = err
            }
            self.performSegue(withIdentifier: "SubmitOrderSegue", sender: nil)
        }
    }
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "SubmitOrderSegue" {
            let orderConfirmationViewController = segue.destination as! OrderConfirmationViewController
            if let error = error {
                orderConfirmationViewController.message = "\(error)"
            } else {
                orderConfirmationViewController.message = "We have got your order.\nPlease keep an eye on your phone 😄"
            }
        }
    }
    
    @IBAction func unwindToCartTableViewController(segue: UIStoryboardSegue) {
        DrinkController.shared.order.drinks.removeAll()
    }
}
