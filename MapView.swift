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
    @EnvironmentObject var locationManager: LocationManager
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
                        Text("location \( locationManager.location?.coordinate.latitude ?? 0.0), \(   locationManager.location?.coordinate.longitude ?? 0.0)")
                        
                        
                        Button("Use Current Location \n") {
                            //get coordinates
//                            currentLat = locationManager.location?.coordinate.latitude ?? 0.00
//                            
//                            currentLong = (locationManager.location?.coordinate.longitude) ?? 0.00
                            
                          

                            
//                            Text("finding bathrooms near \(locationManager.location?.coordinate.longitude) and \(locationManager.location?.coordinate.latitude)")
                            //search nearby locations
                        }
                        Text("Or")
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                            TextField("Enter a location", text: $location)
                                .frame(width: geometry.size.width/3, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .multilineTextAlignment(.center)
                                .onSubmit() {
                                    showPlaceLookupSheet.toggle()
                                }
                        }
                        Text(" \(returnedPlace.name) \nAddr: \(returnedPlace.address) \nCoords: \(returnedPlace.latitude), \(returnedPlace.longitude)")

                        
                    }
                    //                    .toolbar {
                    //                        ToolbarItem {
                    //                            Button{
                    //                                showPlaceLookupSheet.toggle()
                    //                            } label: {
                    //                                Text("Search for a bathroom")
                    //                            }
                    //                            .buttonStyle(.bordered)
                    //                            .frame(alignment: .center)
                    //                        }
                    //                    }
                    
                    
                    
                    
                    //                            Text("Finding bathrooms near \(location)")
                    //                                .multilineTextAlignment(.center)
                    //
              

                    
                    
                }
                //.fullScreenCover / popover
                .fullScreenCover(isPresented: $showPlaceLookupSheet) {
                    PlaceLookupView(returnedPlace: $returnedPlace)
                        .presentationDetents([.height(geometry.size.height/2)])
                }
            }
        }
                
                
            }
        }
    
    
    #Preview {
        MapView()
            .environmentObject(LocationManager())
    }
