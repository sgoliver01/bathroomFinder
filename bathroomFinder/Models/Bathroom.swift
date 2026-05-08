//
//  Bathroom.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 1/17/24.
//

import Foundation
import FirebaseFirestoreSwift
import CoreLocation

struct Bathroom: Identifiable, Codable, Equatable, Hashable {
    @DocumentID var id: String?
    
    var name = ""
    var address = ""
    var latitude = 0.0
    var longitude = 0.0
    var averageRating: Double?
    var reviewCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, address, latitude, longitude, averageRating, reviewCount
    }
    
    var averageRatingValue: Double { averageRating ?? 0 }
    var reviewCountValue: Int { reviewCount ?? 0 }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var dictionary: [String: Any] {
        return ["name": name, "address": address, "latitude": latitude, "longitude": longitude]
    }
}
