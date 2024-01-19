//
//  PlaceViewModel.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 12/26/23.
//

import Foundation
import MapKit


@MainActor

class PlaceViewModel: ObservableObject {
    @Published var places: [Place] = []
    
    func search(text: String, region: MKCoordinateRegion) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        searchRequest.region = region                  //favors results of chains in your "region"/close to you
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            self.places = response.mapItems.map(Place.init)//maps things that search item returns as an individual map item
        }
    }
}
