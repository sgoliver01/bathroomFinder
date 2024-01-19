//
//  MapView.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 12/26/23.
//

import SwiftUI
import MapKit


struct MapView: View {
    
    struct Annotation: Identifiable {
        let id = UUID().uuidString
        var name: String
        var address: String
        var coordinate: CLLocationCoordinate2D
        
    }
    @State private var location = ""
    @EnvironmentObject var locationManager: LocationManager
    @State private var showPlaceLookupSheet = false
    @State var returnedPlace = Place(mapItem: MKMapItem())
    
    let regionSize = 500.0 // meters
    @State var bathroom: Bathroom
    @State private var mapRegion = MKCoordinateRegion()
    @State private var annotations: [Annotation] = [] //empty array of annotation structs we can use to plot on map without having an ID
   
    
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
                        Text("Finding bathroom near \( locationManager.location?.coordinate.latitude ?? 0.0), \(   locationManager.location?.coordinate.longitude ?? 0.0)")
   
                        Map(coordinateRegion: $mapRegion, showsUserLocation: true, annotationItems: annotations) { annotation in
                            MapMarker(coordinate: annotation.coordinate)
                        } // annotationItems is an array of things we want to plot on the map, we can plot anything as long as it is Identifiable and has a coordinate property of CLLocationCoordinate2D
                        .onChange(of: bathroom) { _ in
                            annotations = [Annotation(name: bathroom.name, address: bathroom.address, coordinate: bathroom.coordinate)]
                            mapRegion.center = bathroom.coordinate
                        }
                    }
                    .onAppear {
                        if bathroom.id != nil { //if we have a bathroom, center on location
                            mapRegion = MKCoordinateRegion(center: bathroom.coordinate, latitudinalMeters: regionSize, longitudinalMeters: regionSize)
                        } else { //if we dont have an entry yet and creatig a new one, center on location
                            Task { // if you dont embed in a task, the map update likely wont show
                                mapRegion = MKCoordinateRegion(center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(), latitudinalMeters: regionSize, longitudinalMeters: regionSize)
                                
                            }
                        }
                        annotations = [Annotation(name: bathroom.name, address: bathroom.address, coordinate: bathroom.coordinate)]
                    }
                    
                    
                        
                        
                        
                        
                        //                        Button("Use Current Location \n") {
                        //                            //get coordinates
                        ////                            currentLat = locationManager.location?.coordinate.latitude ?? 0.00
                        ////
                        ////                            currentLong = (locationManager.location?.coordinate.longitude) ?? 0.00
                        //
                        //
                        //
                        //
                        ////                            Text("finding bathrooms near \(locationManager.location?.coordinate.longitude) and \(locationManager.location?.coordinate.latitude)")
                        //                            //search nearby locations
                        //                        }
//                        Text("Or")
                        
//                        HStack {
//                            Image(systemName: "magnifyingglass")
//                            TextField("Enter a location", text: $location)
//                                .frame(width: geometry.size.width/3, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//                                .multilineTextAlignment(.center)
//                                .onSubmit() {
//                                    showPlaceLookupSheet.toggle()
//                                }
//                        }
//                        Text(" \(returnedPlace.name) \nAddr: \(returnedPlace.address) \nCoords: \(returnedPlace.latitude), \(returnedPlace.longitude)")
//                        
//                        
                  
//                                        .toolbar {
//                                            ToolbarItem {
//                                                Button{
//                                                    showPlaceLookupSheet.toggle()
//                                                } label: {
//                                                    Text("Search for a bathroom")
//                                                }
//                                                .buttonStyle(.bordered)
//                                                .frame(alignment: .center)
//                                            }
//                                        }
                    
                    
                    
                    
                    //                            Text("Finding bathrooms near \(location)")
                    //                                .multilineTextAlignment(.center)
                    //
                    
                    
                    
                    
                }
                //.fullScreenCover / popover
//                .fullScreenCover(isPresented: $showPlaceLookupSheet) {
//                    PlaceLookupView(returnedPlace: $returnedPlace)
//                        .presentationDetents([.height(geometry.size.height/2)])
//                }
            }
        }
        
        
    }
}


#Preview {
    MapView(bathroom: Bathroom())
        .environmentObject(LocationManager())
}
