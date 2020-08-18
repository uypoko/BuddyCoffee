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
        DispatchQueue.main.async {
            self.drinkNameLabel.text = drink.name
            self.priceLabel.text = "\(drink.price) đ"
        }
        
        DrinkController.shared.fetchDrinkImage(drinkName: drink.name) { image in
            DispatchQueue.main.async {
                if let image = image {
                    self.drinkImageView.image = self.resizeImage(image: image)
                }
            }
        }
    }
    
    func updateUI(withDrink drinkInOrder: DrinkInOrder) {
        DispatchQueue.main.async {
            self.drinkNameLabel.text = drinkInOrder.drink.name
            self.priceLabel.text = "\(drinkInOrder.quantity)x\(drinkInOrder.drink.price) đ"
        }
        

        DrinkController.shared.fetchDrinkImage(drinkName: drinkInOrder.drink.name) { image in
            DispatchQueue.main.async {
                if let image = image {
                    self.drinkImageView.image = self.resizeImage(image: image)
                }
            }
        }
    }
    
    private func resizeImage(image: UIImage) -> UIImage? {
        let desiredHeight = contentView.bounds.width * 0.2
        let newSize = CGSize(width: desiredHeight, height: desiredHeight)
        let newRect = CGRect(x: 0, y: 0, width: desiredHeight, height: desiredHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: newRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
