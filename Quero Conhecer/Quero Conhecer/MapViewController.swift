//
//  MapViewController.swift
//  Quero Conhecer
//
//  Created by Vinicius Loss on 04/02/23.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viInfo: UIView!
    @IBOutlet weak var lbName: UILabel!
    
    @IBOutlet weak var lbAddress: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func showRoute(_ sender: UIButton) {
    }
    

    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {
    }
}
