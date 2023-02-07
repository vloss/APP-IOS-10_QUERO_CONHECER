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
        mapView.delegate    = self
        
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
        let annotation = PlaceAnnotation(coordinate: place.coordinate, type: .place)
        annotation.title = place.name
        annotation.address = place.address
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

extension MapViewController: MKMapViewDelegate {
    // Usado para modificar uma annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is PlaceAnnotation){
            return nil
        }
        
        let type = (annotation as! PlaceAnnotation).type
        let identifier = "\(type)"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotationView, reuseIdentifier: identifier)
        }
        
        annotationView?.annotation = annotation
        
        return nil
    }
}
