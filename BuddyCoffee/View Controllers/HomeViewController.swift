//
//  HomeViewController.swift
//  BuddyCoffee
//
//  Created by Uy Cung Dinh on 7/3/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var categories: [String] = []
    var drinks: [[Drink]] = []
    @IBOutlet weak var memberInfoView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var membershipLabel: UILabel!
    @IBOutlet weak var drinkTableView: UITableView!
    @IBOutlet var drinkTableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var updatedDrinkTableViewTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drinkTableView.dataSource = self
        drinkTableView.delegate = self
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserUI), name: UserController.authChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDrinkUI), name: DrinkController.drinkUpdatedNotification, object: nil)
        updateDrinkUI()
    }
    
    @objc func updateUserUI() {
        DispatchQueue.main.async {
            if let buddyUser = UserController.shared.buddyUser {
                self.memberInfoView.isHidden = false
                self.updatedDrinkTableViewTopConstraint.isActive = false
                self.drinkTableViewTopConstraint.isActive = true
                self.userNameLabel.text = buddyUser.name
                self.membershipLabel.text = buddyUser.membershipStatus
                UserController.shared.fetchUserImage { image in
                    if let image = image {
                        self.userImageView.image = image
                    } else {
                        self.userImageView.isHidden = true
                    }
                }
            } else {
                self.memberInfoView.isHidden = true
                self.drinkTableViewTopConstraint.isActive = false
                self.updatedDrinkTableViewTopConstraint.isActive = true
            }
        }
    }
    
    @objc func updateDrinkUI() {
        categories = DrinkController.shared.getCategories
        drinks = DrinkController.shared.getDrinks
        drinkTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinks[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "drinkCell", for: indexPath) as! DrinkTableViewCell
        let drink = drinks[indexPath.section][indexPath.row]
        cell.updateUI(withDrink: drink)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        drinkTableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "DrinkDetailSegue" {
            let selectedIndexPath = drinkTableView.indexPathForSelectedRow!
            let drink = drinks[selectedIndexPath.section][selectedIndexPath.row]
            let drinkDetailViewController = segue.destination as! DrinkDetailViewController
            drinkDetailViewController.drink = drink
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserController.shared.addAuthStateListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserController.shared.removeAuthStateListener()
    }

}
