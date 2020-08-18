//
//  DrinkDetailViewController.swift
//  BuddyCoffee
//
//  Created by Ryan on 7/3/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit

class DrinkDetailViewController: UIViewController {

    var drink: Drink?
    var quantity = 0
    
    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var addToCartButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateUI()
    }
    
    func updateUI() {
        guard let drink = drink else { return }
        DispatchQueue.main.async {
            self.drinkNameLabel.text = drink.name
            self.descriptionLabel.text = drink.description
            self.priceLabel.text = "\(drink.price) đ"
        }
        
        DrinkController.shared.fetchDrinkImage(drinkName: drink.name) { image in
            if let image = image {
                DispatchQueue.main.async {
                    self.drinkImageView.image = image
                }
            }
        }
    }

    @IBAction func stepperValueChanged(_ sender: Any) {
        quantity = Int(stepper.value)
        DispatchQueue.main.async {
            self.quantityLabel.text = "\(self.quantity)"
        }
    }
    
    @IBAction func addToCartButtonTapped(_ sender: Any) {
        guard let drink = drink else { return }
        guard quantity != 0 else { return }
        UIView.animate(withDuration: 0.25) {
            self.addToCartButton.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
            self.addToCartButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        if let drinkInOrder = DrinkController.shared.order.drinks.enumerated().first(where: {$0.element.drink == drink}) {
            DrinkController.shared.order.drinks[drinkInOrder.offset].quantity += quantity
        } else {
            DrinkController.shared.order.drinks.append(DrinkInOrder(drink: drink, quantity: quantity))
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
