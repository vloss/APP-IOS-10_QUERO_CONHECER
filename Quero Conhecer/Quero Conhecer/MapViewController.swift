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

    // MARK: Outlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viInfo: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var load: UIActivityIndicatorView!
     
    // MARK: Propriedades
    var places: [Place]!
    var poi: [MKAnnotation] = []

    // lazy para instanciar apenas no momento em que for utilizado o objeto
    lazy var locationManager = CLLocationManager()
    var btUserLocation: MKUserTrackingButton!
    var selectAnnotation: PlaceAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.isHidden          = true
        mapView.mapType             = .mutedStandard
        viInfo.isHidden             = true
        mapView.delegate            = self
        locationManager.delegate    = self
        
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

        annotation.title    = place.name
        annotation.address  = place.address

        mapView.addAnnotation(annotation)
    }
    
    func showPlaces(){
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func showInfo(){
        lbName.text = selectAnnotation!.title
        lbAddress.text = selectAnnotation!.address
        viInfo.isHidden = false
    }
    
    @IBAction func showRoute(_ sender: UIButton) {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            showMessage(type: .authorizationWarning)
            return
        }
        
        let request = MKDirections.Request()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: selectAnnotation!.coordinate)) // define destino
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.location!.coordinate)) // define origem
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if error == nil {
                if let response = response {
                    self.mapView.removeOverlays(self.mapView.overlays)
                    
                    let route = response.routes.first! // devolve todas possíveis rotas em um array
                    print("Nome: ", route.name)
                    print("Distancia: ", route.distance)
                    print("Duração: ", route.expectedTravelTime)
                    print("===================================")
                    for step in route.steps {
                        print("Em \(step.distance) metro(s), \(step.instructions) ")
                    }
                    
                    // adicionando overlays que é tudo que vai em cima do mapa.
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                    
                    var annotations = self.mapView.annotations.filter({!($0 is PlaceAnnotation)}) // Remove tudo deixando apenas localizaão do usuario
                    annotations.append(self.selectAnnotation!)
                    self.mapView.showAnnotations(annotations, animated: true)
                }
            } else {
                self.showMessage(type: .routeError)
            }
        }

    }
    

    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {
        searchBar.resignFirstResponder()
        searchBar.isHidden = !searchBar.isHidden
    }

    func showMessage(type: MapMessageType){
        let title = type == .authorizationWarning ? "Aviso" : "Erro"
        let message = type == .authorizationWarning ? "Para usar os recursos de localização do app, você precisa permetir o acesso na tela de ajustes." : "Não foi possível encontrar esta rota."
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        if type == .authorizationWarning {
            let confirmationAction = UIAlertAction(title: "Ir para Ajustes", style: .default, handler: { (action) in
                
                if let appSettings = URL(string: UIApplicationOpenNotificationSettingsURLString){
                    UIApplication.shared.open(appSettings)
                }
            })
            alert.addAction(confirmationAction)
        }
        present(alert, animated: true)
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let camera = MKMapCamera()
        camera.centerCoordinate = view.annotation!.coordinate
        camera.pitch = 80
        camera.altitude = 100
        mapView.setCamera(camera, animated: true)
        
        
        selectAnnotation = (view.annotation as! PlaceAnnotation)
        showInfo()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline{
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(named: "AccentColor")?.withAlphaComponent(0.8)
            renderer.lineWidth = 5.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
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
        //print(locations.last!)
        // movimenta o mapa conforme a localização muda.
//        if let location = locations.last {
//            print("Velocidade: ", location.speed)
//            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
//            mapView.setRegion(region, animated: true)
//        }
    }
}
