//
//  BathroomDetailView.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 1/18/24.
//

import SwiftUI
import MapKit
import FirebaseFirestoreSwift

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
    //the variable bekow doesnt have the right opath but we will change this in onappear
    @FirestoreQuery(collectionPath: "bathrooms") var reviews: [Review]
    @State var bathroom: Bathroom
    @State private var mapRegion = MKCoordinateRegion()
    @State private var annotations: [Annotation] = [] //empty array of annotation structs we can use to plot on map without having an ID
    @State private var showPlaceLookupSheet = false
    @State private var showReviewViewSheet = false
    @State private var showSaveAlert = false
    @State private var showingAsSheet = false
    var previewRunning = false
    
    
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
            .frame(height: 250)
            .onChange(of: bathroom) { _ in
                annotations.append(Annotation(name: bathroom.name, address: bathroom.address, coordinate: bathroom.coordinate))
                mapRegion.center = bathroom.coordinate
                
            }
            
            List {
                Section {
                 //   Text("going to beat somebody up")
                    
                    ForEach(reviews) { review in
                        NavigationLink {
                            ReviewView(bathroom: bathroom, review: review, reviewVM: ReviewViewModel(), showPlaceLookupSheet: false, dismiss: false)
                        } label: {
                            Text(review.easeOfUse)
                        }
                    }
                        //                    ForEach(reviews) { review in
//                        NavigationLink {
//                            ReviewView(bathroom: bathroom, review: review)
//                        } label: {
//                            Text(review.easeOfUse) //TODO: build a custom cell showing starts, title and body
//                        }
//                    }
                } header: {
                    HStack {
                        Text("Avg. Rating")
                            .font(.title2)
                            .bold()
                        Text("4.5") //TODO: change this to an actual computer property
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundColor(.blue)
                        Spacer()
                        Button("Add Rating") {
                            if bathroom.id == nil {
                                showSaveAlert.toggle()
                            } else {
                                showReviewViewSheet.toggle()
                                //do i need to save something here????? the review????
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .bold()
                        .tint(.blue)
                    }
                }
            }
            .headerProminence(.increased)
            .listStyle(.plain)
            Spacer()
        }
        .onAppear {
            if !previewRunning && bathroom.id != nil { //this is to previent preview provider error
                $reviews.path = "bathrooms/\(bathroom.id ?? "")/reviews"
                print("reviews.path = \($reviews.path)")
                
            } else { // bathroom.id starts out as nil
                showingAsSheet = true
            }
            
            if bathroom.id != nil { //if we have a bathroom, center on location
                mapRegion = MKCoordinateRegion(center: bathroom.coordinate, latitudinalMeters: regionSize, longitudinalMeters: regionSize)
            } else { //if we dont have an entry yet and creatig a new one, center on location
                Task { // if you dont embed in a task, the map update likely wont show
                    mapRegion = MKCoordinateRegion(center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(), latitudinalMeters: regionSize, longitudinalMeters: regionSize)
                    
                }
            }
            annotations.append(Annotation(name: bathroom.name, address: bathroom.address, coordinate: bathroom.coordinate))
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(bathroom.id == nil)
        .toolbar {
            if showingAsSheet { //New spot so show cancel and save buttons and lookup place at bottom
                if bathroom.id == nil && showingAsSheet { //new spot so show cancel/save button
                   
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            Task {
                                let success = await bathroomVM.saveBathroom(bathroom: bathroom)
                                //THIS MIGHT BE THE WRONG THING TO DO HERE BUT IT HINK ITS RIGHT
                                bathroom = bathroomVM.bathroom
                               // print("bathroom saved \(bathroom.id)")
                                print("this is a full list of reviews \(reviews)")
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
                } else if showingAsSheet && bathroom.id != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                
            }
        }
        .sheet(isPresented: $showPlaceLookupSheet) {
            PlaceLookupView(bathroom: $bathroom)
        }
        .sheet(isPresented: $showReviewViewSheet) {
            NavigationStack {
                ReviewView(bathroom: bathroom, review: Review())
            }
        }
        .alert("Cannot Rate Bathroom Unless It is Saved", isPresented: $showSaveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Save", role: .none) {
                Task {
                    let success = await bathroomVM.saveBathroom(bathroom: bathroom)
                    bathroom = bathroomVM.bathroom
                    print(bathroom.id)
                    print("success = \(success)")
                    if success {
                        //if we didnt update the path after we saved the spot, we wouldnt be able to make a review
                        $reviews.path = "bathrooms/\(bathroom.id ?? "")/reviews"
                        print("updating review path to \($reviews.path)")
                        print("showing all reviews \(reviews)")
                        showReviewViewSheet.toggle()
                    } else {
                        print("error saving bathroom")
                    }
                }
            }
        } message: {
            Text("Would you like to save this alert first so that you can enter a review?")
        }
        
        
    }
}


struct BathroomDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BathroomDetailView(bathroom: Bathroom(), previewRunning: true)
                .environmentObject(BathroomViewModel())
                .environmentObject(LocationManager())
        }
    }
}
