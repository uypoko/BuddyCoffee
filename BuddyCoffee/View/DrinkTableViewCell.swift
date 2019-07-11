//
//  DrinkTableViewCell.swift
//  BuddyCoffee
//
//  Created by Ryan on 7/3/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit

class DrinkTableViewCell: UITableViewCell {

    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(withDrink drink: Drink) {
        drinkNameLabel.text = drink.name
        priceLabel.text = "\(drink.price) đ"
        DrinkController.shared.fetchDrinkImage(drinkName: drink.name) { image in
            if let image = image {
                DispatchQueue.main.async {
                    self.drinkImageView.image = image
                }
            }
        }
    }
    
    func updateUI(withDrink drinkInOrder: DrinkInOrder) {
        drinkNameLabel.text = drinkInOrder.drink.name
        priceLabel.text = "\(drinkInOrder.quantity)x\(drinkInOrder.drink.price) đ"
        DrinkController.shared.fetchDrinkImage(drinkName: drinkInOrder.drink.name) { image in
            if let image = image {
                DispatchQueue.main.async {
                    self.drinkImageView.image = image
                }
            }
        }
    }
}
