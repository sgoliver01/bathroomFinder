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
    @EnvironmentObject var bathroomVM: BathroomViewModel
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var favoritesVM = FavoritesViewModel()
    @FirestoreQuery(collectionPath: "bathrooms/placeholder/reviews") var reviews: [Review]
    @State var bathroom: Bathroom
    @State private var showReviewViewSheet = false
    @State private var showSaveAlert = false
    var previewRunning = false
    var presentedAsSheet = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(bathroom.name)
                .font(.title)
                .bold()
                .padding(.horizontal)
            
            HStack {
                Text(bathroom.address)
                    .font(.title3)
                    .foregroundColor(.gray)
                Spacer()
                if !reviews.isEmpty {
                    let avg = reviews.map { $0.overallRating }.reduce(0, +) / Double(reviews.count)
                    HStack(spacing: 4) {
                        Text("💩")
                        Text(String(format: "%.1f", avg))
                            .font(.title3)
                            .bold()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            Button {
                let coordinate = bathroom.coordinate
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
                mapItem.name = bathroom.name
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
            } label: {
                Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Divider()
            
            if reviews.isEmpty {
                VStack {
                    Spacer()
                    Text("No ratings yet")
                        .foregroundColor(.gray)
                    Button("Add Rating") {
                        showReviewViewSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List(reviews) { review in
                    NavigationLink {
                        ReviewDetailView(review: review)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(String(format: "%.1f/5", review.overallRating))
                                        .font(.headline)
                                        .bold()
                                    Text("💩")
                                        .font(.caption)
                                }
                                Text("by \(review.reviewerValue)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text(review.postedOnValue, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .onAppear {
            if !previewRunning && bathroom.id != nil {
                $reviews.path = "bathrooms/\(bathroom.id ?? "")/reviews"
            }
            favoritesVM.fetchFavorites()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(bathroom.id == nil)
        .toolbar {
            if bathroom.id != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showReviewViewSheet = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        
                        Button {
                            if favoritesVM.isFavorite(bathroom) {
                                favoritesVM.removeFavorite(bathroom)
                            } else {
                                favoritesVM.addFavorite(bathroom)
                            }
                        } label: {
                            Image(systemName: favoritesVM.isFavorite(bathroom) ? "heart.fill" : "heart")
                                .foregroundColor(.red)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if presentedAsSheet {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showReviewViewSheet) {
            NavigationStack {
                ReviewView(bathroom: bathroom, review: Review(), canDismiss: true)
            }
        }
        .alert("Cannot Rate Bathroom Unless It is Saved", isPresented: $showSaveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Save", role: .none) {
                Task {
                    let success = await bathroomVM.saveBathroom(bathroom: bathroom)
                    bathroom = bathroomVM.bathroom
                    if success {
                        $reviews.path = "bathrooms/\(bathroom.id ?? "")/reviews"
                        showReviewViewSheet.toggle()
                    }
                }
            }
        } message: {
            Text("Would you like to save this bathroom first so that you can enter a review?")
        }
    }
}

#Preview {
    NavigationStack {
        BathroomDetailView(bathroom: Bathroom(), previewRunning: true)
            .environmentObject(BathroomViewModel())
            .environmentObject(LocationManager())
    }
}
