//
//  BathroomDetailView.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 1/18/24.
//

import SwiftUI
import MapKit

struct BathroomDetailView: View {
    //declaring this so that we can plot all places even if they dont have an ID - we assign one
    struct Annotation: Identifiable {
        let id = UUID().uuidString
        var name: String
        var address: String
        var coordinate: CLLocationCoordinate2D
        
    }
    
    @EnvironmentObject var bathroomVM: BathroomViewModel
    @EnvironmentObject var locationManager: LocationManager
    @State var bathroom: Bathroom
    @State private var mapRegion = MKCoordinateRegion()
    @State private var annotations: [Annotation] = [] //empty array of annotation structs we can use to plot on map without having an ID
    @State private var showPlaceLookupSheet = false
    
    
    @Environment(\.dismiss) private var dismiss
    let regionSize = 500.0 // meters
    
    var body: some View {
        VStack {
            Group {
                TextField("Name", text: $bathroom.name)
                    .font(.title)
                TextField("Address", text: $bathroom.address)
                    .font(.title2)
            }
            .disabled(bathroom.id == nil ? false : true)
            .textFieldStyle(.roundedBorder)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray.opacity(0.5), lineWidth: bathroom.id == nil ? 2 : 0)
            }
            .padding(.horizontal)
            
            Map(coordinateRegion: $mapRegion, showsUserLocation: true, annotationItems: annotations) { annotation in
                MapMarker(coordinate: annotation.coordinate)
            } // annotationItems is an array of things we want to plot on the map, we can plot anything as long as it is Identifiable and has a coordinate property of CLLocationCoordinate2D
            .onChange(of: bathroom) { _ in
                annotations = [Annotation(name: bathroom.name, address: bathroom.address, coordinate: bathroom.coordinate)]
                mapRegion.center = bathroom.coordinate
            }
            
            Spacer()
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
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(bathroom.id == nil)
        .toolbar {
            if bathroom.id == nil { //new spot so show cancel/save button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            let success = await bathroomVM.saveBathroom(bathroom: bathroom)
                            if success {
                                dismiss()
                            } else {
                                print("error saving bathroom")
                            }
                        }
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    
                    Button {
                        showPlaceLookupSheet.toggle()
                    } label: {
                        Image(systemName: "magnifyingglass")
                        Text("Lookup Place")
                    }
                }
            }
        }
        .sheet(isPresented: $showPlaceLookupSheet) {
            PlaceLookupView(bathroom: $bathroom)
        }
      
    }
}


struct BathroomDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BathroomDetailView(bathroom: Bathroom())
                .environmentObject(BathroomViewModel())
                .environmentObject(LocationManager())
        }
    }
}
