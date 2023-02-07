//
//  PlaceAnnotation.swift
//  Quero Conhecer
//
//  Created by Vinicius Loss on 06/02/23.
//

import Foundation
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    
    enum PlaceType {
        case place // Lugar
        case poi // Ponto de Interesse
    }
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: PlaceType
    var address: String?
    
    init(coordinate: CLLocationCoordinate2D, type: PlaceType) {
        self.coordinate = coordinate
        self.type = type
    }
}
