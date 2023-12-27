//
//  PlaceLookupView.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 12/26/23.
//

import SwiftUI
import MapKit

struct PlaceLookupView: View {
    @EnvironmentObject var locationManager: LocationManager
    @StateObject var placeVM = PlaceViewModel() //we can init as a @STATEObject here if this is the first or only place well use this view model
    @State private var searchText = " "
    @Binding var returnedPlace: Place
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                List(placeVM.places) { place in
                    VStack(alignment: .leading) {
                        Text(place.name)
                            .font(.title2)
                        Text(place.address)
                            .font(.callout)
                    }
                    .onTapGesture {
                        returnedPlace = place
                        dismiss()
                    }
                    
                }
                .listStyle(.plain)
                .searchable(text: $searchText)
                //            .onChange(of: searchText, { text, text in
                //
                //            })
                //
            
                .onChange(of: searchText, perform: { text in
                    if !text.isEmpty {
                        placeVM.search(text: text, region: locationManager.region)
                    } else {
                        placeVM.places = []
                    }
                })
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
            .padding(.top, geometry.size.height * 1/2)
        .frame(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}

#Preview {
    PlaceLookupView(returnedPlace: .constant(Place(mapItem: MKMapItem())))
        .environmentObject(LocationManager())
}
