//
//  Place.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 12/26/23.
//

import Foundation
import MapKit

struct Place: Identifiable {
    let id = UUID().uuidString
    private var mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
    
    var name: String {
        self.mapItem.name ?? "" // ?? means that if mapItem.name returns nil, dont use nil but instead just give it the name empty string "" so it doesnt create an error
    }
    
    var address: String {
        let placemark = self.mapItem.placemark                      //TODO: look this up later to get more info regarding each place like hours and if there are bvathrooms
        var cityAndState = ""
        var address = ""
        
        cityAndState = placemark.locality ?? "" //city
        if let state = placemark.administrativeArea {
            //show either state or city,state
            cityAndState = cityAndState.isEmpty ? state: "\(cityAndState), \(state)"
        }
        
        address = placemark.subThoroughfare ?? "" //addres #
        if let street = placemark.thoroughfare {
            //just show streeth unless also street number and then add space + street
            address = address.isEmpty ? street : "\(address) \(street)"
        }
        
        if address.trimmingCharacters(in: .whitespaces).isEmpty && !cityAndState.isEmpty {//whitespaces means it removes white spaces/trims white characters and is still an empty string
            address = cityAndState
        } else {
            //no city ad state, then just address, otherwise address, city and state
            address = cityAndState.isEmpty ? address : "\(address), \(cityAndState)"
        }
        return address
    }
    var latitude: CLLocationDegrees {
        self.mapItem.placemark.coordinate.latitude
    }
    var longitude: CLLocationDegrees {
        self.mapItem.placemark.coordinate.longitude
    }
}
