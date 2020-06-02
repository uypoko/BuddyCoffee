//
//  FindMyLocationOnMapsViewController.swift
//  BuddyCoffee
//
//  Created by Uy Cung Dinh on 6/2/20.
//  Copyright © 2020 Equity. All rights reserved.
//

import UIKit
import GoogleMaps

class FindMyLocationOnMapsViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    let locationManager =  CLLocationManager()
    weak var deliveryAddressDidSetDelegate: DeliveryAddressDidSetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        mapView.delegate = self
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
    
    @IBAction func setLocationButtonTapped(_ sender: Any) {
        if let address = addressLabel.text, address != "Your Address" {
            deliveryAddressDidSetDelegate?.didSetLocation(address: address)
            print("Find: \(address)")
            dismiss(animated: true, completion: nil)
        }
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
                self?.addressLabel.text = addressString
            }
        }
    }
    
    func showAlert(message: String, completion: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true, completion: nil)
    }

}

// MARK: CLLocationManagerDelegate
extension FindMyLocationOnMapsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
          return
        }
        
        locationManager.requestLocation()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        reverseGeocode(coordinate: location.coordinate)
        
        // Zoom camera to the current location
        mapView.camera = GMSCameraPosition(
            target: location.coordinate,
            zoom: 15,
            bearing: 0,
            viewingAngle: 0)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

protocol DeliveryAddressDidSetDelegate: class {
    func didSetLocation(address: String)
}

extension FindMyLocationOnMapsViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        // Update address label when position of the map changes
        reverseGeocode(coordinate: position.target)
    }
}
