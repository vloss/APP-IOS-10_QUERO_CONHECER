//
//  Place.swift
//  Quero Conhecer
//
//  Created by Vinicius Loss on 04/02/23.
//

import Foundation
import MapKit


struct Place {
    let name: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let address: String
    
    var coordinate: CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static func getFormattedAddress(with placemark: CLPlacemark) -> String{
        
        var address = ""
        
        // Rua
        if let street = placemark.thoroughfare{
            address += street
        }
        
        // Numero da rua
        if let number = placemark.subThoroughfare{
            address += " \(number)"
        }
        
        // Bairro
        if let subLocality = placemark.subLocality {
            address += ", \(subLocality)"
        }
        
        // Cidade
        if let city = placemark.locality {
            address += "\n\(city)"
        }
        // Estado
        if let state = placemark.administrativeArea {
            address += " - \(state)"
        }
        // CEP
        if let postalCode = placemark.postalCode {
            address += "\nCEP: \(postalCode)"
        }
        // Pais
        if let country = placemark.country {
            address += "\n\(country)"
        }

        return address
    }
}
