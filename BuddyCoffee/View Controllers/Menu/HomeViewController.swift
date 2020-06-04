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
    @IBOutlet weak var userInforStackView: UIStackView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var membershipLabel: UILabel!
    @IBOutlet weak var drinkTableView: UITableView!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make userImageView appear circular
        userImageView.layer.cornerRadius = userImageView.frame.width / 2.0
        userImageView.clipsToBounds = true
        
        userImageView.isHidden = true
        userInforStackView.isHidden = true
        drinkTableView.dataSource = self
        drinkTableView.delegate = self
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserUI), name: UserController.authChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDrinkUI), name: DrinkController.drinkUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfilePicture), name: UserController.profilePictureChangedNotification, object: nil)
        updateDrinkUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserController.shared.addAuthStateListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserController.shared.removeAuthStateListener()
    }
    
    @objc func updateUserUI() {
        DispatchQueue.main.async {
            if let buddyUser = UserController.shared.buddyUser {
                self.userInforStackView.isHidden = false
                self.userNameLabel.text = buddyUser.name
                self.membershipLabel.text = buddyUser.membershipStatus
            } else {
                self.userNameLabel.text = nil
                self.membershipLabel.text = nil
                self.userImageView.image = nil
                self.userInforStackView.isHidden = true
            }
        }
    }
    
    @objc func updateDrinkUI() {
        categories = DrinkController.shared.getCategories
        drinks = DrinkController.shared.getDrinks
        drinkTableView.reloadData()
    }
    
    @objc func updateProfilePicture() {
        UserController.shared.fetchUserImage { image in
            DispatchQueue.main.async {
                self.userImageView.image = image
                if image != nil {
                    self.userImageView.isHidden = false
                } else {
                    self.userImageView.isHidden = true
                }
            }
        }
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

}
