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
    
    var places: [Place]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.isHidden  = true
        viInfo.isHidden     = true
        
        if places.count == 1 {
            title = places[0].name
        } else {
            title = "Meus Lugares"
        }
        
        for place in places {
            addToMap(place)
        }
        
        showPlaces()
    }
    
    func addToMap (_ place: Place){
        let annotation = MKPointAnnotation()
        annotation.coordinate = place.coordinate
        annotation.title = place.name
        mapView.addAnnotation(annotation)
    }
    
    func showPlaces(){
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    @IBAction func showRoute(_ sender: UIButton) {
    }
    

    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {
    }
}
