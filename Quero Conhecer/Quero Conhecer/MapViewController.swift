//
//  MapViewController.swift
//  Quero Conhecer
//
//  Created by Vinicius Loss on 04/02/23.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    enum MapMessageType {
        case routeError
        case authorizationWarning
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viInfo: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var load: UIActivityIndicatorView!
    
    var places: [Place]!
    var poi: [MKAnnotation] = []

    // lazy para instanciar apenas no momento em que for utilizado o objeto
    lazy var locationManager = CLLocationManager()
    var btUserLocation: MKUserTrackingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.isHidden  = true
        mapView.mapType = .mutedStandard
        viInfo.isHidden     = true
        mapView.delegate    = self
        locationManager.delegate = self
        
        if places.count == 1 {
            title = places[0].name
        } else {
            title = "Meus Lugares"
        }
        
        for place in places {
            addToMap(place)
        }
        
        configureLocationButton()
        
        showPlaces()
        requestUserLocationAuthorization()
    }
    
    func configureLocationButton(){
        btUserLocation = MKUserTrackingButton(mapView: mapView)
        btUserLocation.backgroundColor = .white
        btUserLocation.frame.origin.x = 10
        btUserLocation.frame.origin.y = 10
        btUserLocation.layer.cornerRadius = 5
        btUserLocation.layer.borderWidth = 1
        btUserLocation.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
    }
    
    func requestUserLocationAuthorization() {
        // Validação de
        if CLLocationManager.locationServicesEnabled(){
            switch CLLocationManager.authorizationStatus() {
                // Valida se está sempre autorizado ou só no uso
                case .authorizedAlways, .authorizedWhenInUse:
                    // Mostrar o botão de localização no mapa
                mapView.addSubview(btUserLocation)
                // Sem autorização
                case .denied:
                    showMessage(type: .authorizationWarning)

                // Ainda não solicitou nenhuma autorização
                case .notDetermined:
                    // requisição de autorização quando o app estiver em uso.
                    locationManager.requestWhenInUseAuthorization()
                case .restricted:
                    break
            }
        } else {
            // não tem
        }
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
        searchBar.resignFirstResponder()
        searchBar.isHidden = !searchBar.isHidden
    }

    func showMessage(type: MapMessageType){
//        let title: String, message: String
//        var hasConfirmation: Bool = false
//
//        switch type {
//        case .confirmation(let name):
//            title = "Local Encontrado"
//            message = "Deseja adicionar \(name)?"
//            hasConfirmation = true
//
//        case .error(let erroMessage):
//            title = "Erro"
//            message = erroMessage
//        }
//
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
//        alert.addAction(cancelAction)
//        if hasConfirmation{
//            let confirmationAction = UIAlertAction(title: "Ok", style: .default) { (action) in
//                self.delegate?.addPlace(self.place)
//                self.dismiss(animated: true)
//            }
//            alert.addAction(confirmationAction)
//        }
//
//        present(alert, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    // Usado para modificar uma annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is PlaceAnnotation){
            return nil
        }
        
        // Realizado cast para PlaceAnnotation pois o type só existe na classe criada.
        let type = (annotation as! PlaceAnnotation).type
        let identifier = "\(type)"
        
        // Recupera uma annotation view para reuso - Necessário atribuir os novos valores, pois se já existe irá trazer tudo.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        // Se nil segnifica que é a primeira vez que está sendo usada
        if annotationView == nil {
            // Criando uma annotation viewnMKMarkerAnnotationView
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        annotationView?.annotation = annotation
        annotationView?.canShowCallout = true
        annotationView?.markerTintColor = type == .place ? UIColor(named: "AccentColor") : UIColor(named: "poi")
        annotationView?.glyphImage = type == .place ? UIImage(named: "placeGlyph") : UIImage(named: "poiGlyph")
        annotationView?.displayPriority = type == .place ? .required : .defaultHigh
        
        return annotationView
    }
}

extension MapViewController: UISearchBarDelegate{

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        load.startAnimating()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        
        // Responsavel por executar a requisição
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error == nil {
                guard let response = response else {
                    self.load.stopAnimating()
                    return
                }
                
                self.mapView.removeAnnotations(self.poi)
                self.poi.removeAll()
                
                for item in response.mapItems {
                    let annotation = PlaceAnnotation(coordinate: item.placemark.coordinate, type: .poi)
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    annotation.address = Place.getFormattedAddress(with: item.placemark)
                    self.poi.append(annotation)
                }
                
                self.mapView.addAnnotations(self.poi)
                self.mapView.showAnnotations(self.poi, animated: true)
            }
            self.load.stopAnimating()
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    // Semrpe que o estado da autorização for alterado.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
            mapView.addSubview(btUserLocation)
            locationManager.startUpdatingLocation()
            
        default:
            break
        }
    }
    
    // sempre que usuario mudar a localização.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last!)
    }
}
