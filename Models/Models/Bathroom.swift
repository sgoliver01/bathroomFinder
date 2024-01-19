//
//  Bathroom.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 1/17/24.
//

import Foundation
import FirebaseFirestoreSwift
import CoreLocation

struct Bathroom: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    
    var name = ""
    var address = ""
    var latitude = 0.0
    var longitude = 0.0
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    
    var dictionary: [String: Any] {
        return ["name": name, "address": address, "latitude": latitude, "longitutde": longitude]
    }
}
