//
//  PlaceFinderViewController.swift
//  Quero Conhecer
//
//  Created by Vinicius Loss on 04/02/23.
//

import UIKit
import MapKit

protocol PlaceFinderDelegate: class {
    func addPlace(_ place: Place)
}

class PlaceFinderViewController: UIViewController {
    
    enum placeFinderMessageType {
        case error(String)
        case confirmation(String)
    }

    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    @IBOutlet weak var viLoading: UIView!
    
    var place: Place!
    weak var delegate: PlaceFinderDelegate?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(getLocation(_: )))
        gesture.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(gesture)

    }

    @objc func getLocation(_ gesture: UILongPressGestureRecognizer){
        // pega o status da ação
        if gesture.state == .began{
            load(show: true)
            
            // Pega a localização x e y do longo click na view
            let point = gesture.location(in: mapView)
            
            // converte os pontos x e y da tela em coordenadas no mapview
            let cordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            // Converte as coordenadas lat e lon em localizacão
            let location = CLLocation(latitude: cordinate.latitude, longitude: cordinate.longitude)
            
            // Instancia classe Core Location Geocoder
            let geoCoder = CLGeocoder()
            
            // Passa location com lat e lon
            geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in

                // por estar em uma clouser é necessário usar self
                self.load(show: false)
                
                if error == nil {
                    if !self.savePlace(with: placemarks?.first){
                        self.showMessage(type: .error("Não foi encontrado nenhum local com esse nome"))
                    }
                } else {
                    self.showMessage(type: .error("Erro Desconhecido"))
                }
            }
        }
    }
    
    
    @IBAction func findCity(_ sender: UIButton) {
        // Ao terminar de digitar fechar teclado
        tfCity.resignFirstResponder()
        
        //get string
        let address = tfCity.text!
        
        // Abre tela carregando
        load(show: true)
        
        // Instancia classe Core Location Geocoder
        let geoCoder = CLGeocoder()
        
        // Passa string com endereço
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            // por estar em uma clouser é necessário usar self
            self.load(show: false)
            
            if error == nil {
                if !self.savePlace(with: placemarks?.first){
                    self.showMessage(type: .error("Não foi encontrado nenhum local com esse nome"))
                }
            } else {
                self.showMessage(type: .error("Erro Desconhecido"))
            }
        }
    }
    
    func savePlace(with placemark: CLPlacemark?) -> Bool {
        
        guard let placemark = placemark, let coordinate = placemark.location?.coordinate else {
            return false
        }
        
        // Colocar ?? para os casos que não exista o optional
        let name = placemark.name ?? placemark.country ?? "Desconhecido"
        let address = Place.getFormattedAddress(with: placemark)
        
        place = Place(name: name, latitude: coordinate.latitude, longitude: coordinate.longitude, address: address)
        
        //let region = MKCoordinateRegionMakeWithDistance(coordinate, 3500, 3500)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 3500, longitudinalMeters: 3500)
        
        mapView.setRegion(region, animated: true)
        
        self.showMessage(type: .confirmation(place.name))
        
        return true
    }
    
    func showMessage(type: placeFinderMessageType){
        let title: String, message: String
        var hasConfirmation: Bool = false
        
        switch type {
        case .confirmation(let name):
            title = "Local Encontrado"
            message = "Deseja adicionar \(name)?"
            hasConfirmation = true

        case .error(let erroMessage):
            title = "Erro"
            message = erroMessage
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        if hasConfirmation{
            let confirmationAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                self.delegate?.addPlace(self.place)
                self.dismiss(animated: true)
            }
            alert.addAction(confirmationAction)
        }

        present(alert, animated: true)
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
