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

    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findCity(_ sender: UIButton) {
        
    }
}
