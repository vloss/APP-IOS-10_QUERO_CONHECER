//
//  PlaceFinderViewController.swift
//  Quero Conhecer
//
//  Created by Vinicius Loss on 04/02/23.
//

import UIKit
import MapKit

class PlaceFinderViewController: UIViewController {

    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    @IBOutlet weak var viLoading: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func findCity(_ sender: UIButton) {
        tfCity.resignFirstResponder()
        let address = tfCity.text!
        
        load(show: true)
        
        // Core Location Geocoder
        let geoCoder = CLGeocoder()
        
        // Passa string com endereço
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            // por estar em uma clouser é necessário usar self
            self.load(show: false)
            
            // desembrulhar
            guard let placemark = placemarks?.first else {return}
            
            print(Place.getFormattedAddress(with: placemark))
            
            
        }
        
    }
    
    func load(show: Bool){
        // Oculta e mostra view
        viLoading.isHidden = !show
        
        // Inicia e pausa o loading
        if show {
            aiLoading.startAnimating()
        } else {
            aiLoading.stopAnimating()
        }
    }

    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
