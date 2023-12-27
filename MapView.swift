//
//  MapView.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 12/26/23.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var location = ""
    @State private var showPlaceLookupSheet = false
    @State var returnedPlace = Place(mapItem: MKMapItem())
    
    var body: some View {
        
        GeometryReader {geometry in
            
            NavigationStack {
                ZStack {
                    Rectangle()
                        .fill(
                            Gradient(colors: [.white, Color("dullGray"), .black])
                        )
                        .opacity(0.5)
                        .ignoresSafeArea()
                    
                    
                    
                    
                    VStack {
                      
                        //                        .toolbar(content: {
                        //                            ToolbarItem {
                        //                                Button{
                        //                                    showPlaceLookupSheet.toggle()
                        //                                } label: {
                        //                                    Text("Lookup Place")
                        //                                }
                        //                                .buttonStyle(.bordered)
                        //                                .frame(alignment: .center)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                            TextField("Enter a location", text: $location)
                                .frame(width: geometry.size.width/3, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .multilineTextAlignment(.center)
                                .onSubmit() {
                                    showPlaceLookupSheet.toggle()
                                }
                        }
                        //                            }
                        //                        })
                        
                        Text("Finding bathrooms near \(location)")
                            .multilineTextAlignment(.center)
                        
                        Text("Returned Place: \nName: \(returnedPlace.name) \nAddr: \(returnedPlace.address) \nCoords: \(returnedPlace.latitude), \(returnedPlace.longitude)")
                    }
                }
                
            }
            .fullScreenCover(isPresented: $showPlaceLookupSheet) {
                PlaceLookupView(returnedPlace: $returnedPlace)
            }
            
            
        }
    }
}

#Preview {
    MapView()
}
