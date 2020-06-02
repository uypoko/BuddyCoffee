//
//  DeliveryAddressViewController.swift
//  BuddyCoffee
//
//  Created by Uy Cung Dinh on 7/17/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class DeliveryAddressViewController: UIViewController {

    var orderTotal: Int?
    let locationManager =  CLLocationManager()
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var addressTextView: AddressTextView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        addressTextView.configure()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: DrinkController.orderUpdatedNotification, object: nil)
        updateUI()
        locationManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserController.shared.addAuthStateListener()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserController.shared.removeAuthStateListener()
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
            break
        case .denied:
            showAlert(message: "Permission for location has been denied, you need to enable location service in Settings", completion: nil)
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            showAlert(message: "Permission for location has been restricted", completion: nil)
            break
        case .authorizedAlways:
            break
        }
    }
    
    func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let geoCoder = GMSGeocoder()
        
        geoCoder.reverseGeocodeCoordinate(coordinate) { [weak self] response, error in
            guard let address = response?.firstResult(),
                let lines = address.lines else { return }
            let addressString = lines.joined(separator: " ")
            
            DispatchQueue.main.async {
                self?.addressTextView.text = addressString
            }
        }
    }
    
    @objc func updateUI() {
        if let user = UserController.shared.buddyUser {
            emailField.text = user.email
            emailField.isUserInteractionEnabled = false
            nameField.text = user.name
            phoneNumberField.text = "\(user.phone)"
            addressTextView.text = user.address
            addressTextView.textColor = .black
        }
    }
    
    @IBAction func placeOrderButtonTapped(_ sender: Any) {
        guard let total = orderTotal else { return }
        do {
            let email = try emailField.validatedText(validationType: .email)
            let name = try nameField.validatedText(validationType: .requiredField(field: "Name"))
            let phone = try phoneNumberField.validatedText(validationType: .phone)
            let address = try addressTextView.validatedText(validationType: .requiredField(field: "Address"))

            let alert = UIAlertController(title: "Confirm Order", message: "You're about to submit the order with the total of \(total)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Submit", style: .default) { action in
                self.uploadOrder(email: email, name: name, phone: phone, address: address, total: total)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } catch (let error) {
            showAlert(message: (error as! ValidationError).message, completion: nil)
        }
    }
    
    func uploadOrder(email: String, name: String, phone: String, address: String, total: Int) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        DrinkController.shared.submitOrder(email: email, name: name, phone: phone, address: address, total: total) { error in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.view.isUserInteractionEnabled = true
            if let error = error {
                self.showAlert(message: error.localizedDescription, completion: nil)
            } else {
                self.performSegue(withIdentifier: "PlaceOrderSegue", sender: nil)
            }
        }
    }
    
    func showAlert(message: String, completion: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PlaceOrderSegue" {
            let orderConfirmationViewController = segue.destination as! OrderConfirmationViewController
            orderConfirmationViewController.message = "We've got your order.\nPlease keep an eye on your phone 😄"
        }
    }

}

// MARK: CLLocationManagerDelegate
extension DeliveryAddressViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
          return
        }
        
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let first = locations.first {
            reverseGeocode(coordinate: first.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
