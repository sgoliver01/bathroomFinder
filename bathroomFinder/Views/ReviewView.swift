//
//  RateView.swift
//  bathroomFinder
//
//  Created by Sarah Oliver on 12/26/23.
//

import SwiftUI

struct ReviewView: View {
    @State var bathroom: Bathroom
    @State var review: Review
    @EnvironmentObject var bathroomVM: BathroomViewModel
    @StateObject var reviewVM = ReviewViewModel()
    var canDismiss: Bool = false
    
    @State private var showPlaceLookupSheet = false
    @State private var showSavedAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Bathroom info
                VStack(alignment: .leading) {
                    if bathroom.name.isEmpty {
                        Button {
                            showPlaceLookupSheet.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Lookup Bathroom")
                            }
                            .font(.title3)
                            .fontWeight(.semibold)
                        }
                    } else {
                        Text(bathroom.name)
                            .font(.title)
                            .bold()
                        Text(bathroom.address)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Rating instructions
                Text("Rate each category 1-5 (5💩 = best)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Rating fields
                VStack(alignment: .leading, spacing: 16) {
                    RatingRow(label: "Ease of Use", description: "Was the bathroom easy to find and access?", rating: Binding(get: { review.easeOfUse ?? 0 }, set: { review.easeOfUse = $0 }))
                    RatingRow(label: "Wait Time", description: "How short was the wait for the bathroom?", rating: Binding(get: { review.waitTime ?? 0 }, set: { review.waitTime = $0 }))
                    RatingRow(label: "Toilet Paper", description: "Was it stocked and good quality?", rating: Binding(get: { review.toiletPaper ?? 0 }, set: { review.toiletPaper = $0 }))
                    RatingRow(label: "Cleanliness", description: "How clean was the bathroom?", rating: Binding(get: { review.cleanliness ?? 0 }, set: { review.cleanliness = $0 }))
                }
                .padding(.horizontal)
                
                Divider()
                
                // Overall rating display
                HStack {
                    Text("Overall Rating:")
                        .font(.headline)
                    Spacer()
                    Text("💩")
                    Text(String(format: "%.1f", review.overallRating))
                        .font(.title)
                        .bold()
                    Text("/ 5")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Divider()
                
                // Additional comments
                VStack(alignment: .leading) {
                    Text("Additional Comments")
                        .font(.headline)
                    TextField("Write your comments here...", text: Binding(get: { review.body ?? "" }, set: { review.body = $0 }), axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .frame(minHeight: 80, alignment: .top)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Rate Bathroom 🚽")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    Task {
                        let successBathroom = await bathroomVM.saveBathroom(bathroom: bathroom)
                        bathroom = bathroomVM.bathroom
                        
                        let successReview = await reviewVM.saveReview(bathroom: bathroom, review: review)
                        if successBathroom && successReview {
                            showSavedAlert = true
                        } else {
                            print("error saving bathroom and/or review")
                        }
                    }
                }
                .disabled(bathroom.name.isEmpty)
            }
            
        }
        .sheet(isPresented: $showPlaceLookupSheet) {
            PlaceLookupView(bathroom: $bathroom)
        }
        .alert("Review saved! 💩", isPresented: $showSavedAlert) {
            Button("OK") {
                if canDismiss {
                    dismiss()
                } else {
                    review = Review()
                    bathroom = Bathroom()
                }
            }
        }
    }
}

/// A single rating row with label, description + poop selector
struct RatingRow: View {
    let label: String
    var description: String = ""
    @Binding var rating: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(label)
                    .font(.subheadline)
                    .bold()
                if !description.isEmpty {
                    Text("— \(description)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            PoopsSelectionView(rating: $rating)
        }
    }
}

#Preview {
    NavigationStack {
        ReviewView(bathroom: Bathroom(name: "Shake Shack", address: "49 Boylston St."), review: Review())
            .environmentObject(BathroomViewModel())
    }
}
