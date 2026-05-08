//
//  ReviewDetailView.swift
//  bathroomFinder
//

import SwiftUI

struct ReviewDetailView: View {
    let review: Review
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Overall rating
                HStack {
                    Text("Overall:")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Text(String(format: "%.1f / 5", review.overallRating))
                        .font(.title)
                        .bold()
                }
                
                // Reviewer and date
                HStack {
                    Text("by \(review.reviewerValue)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(review.postedOnValue, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Divider()
                
                // Individual ratings
                RatingDisplayRow(label: "Ease of Use", rating: review.easeOfUseValue)
                RatingDisplayRow(label: "Wait Time", rating: review.waitTimeValue)
                RatingDisplayRow(label: "Toilet Paper", rating: review.toiletPaperValue)
                RatingDisplayRow(label: "Cleanliness", rating: review.cleanlinessValue)
                
                if !review.bodyValue.isEmpty {
                    Divider()
                    Text("Additional Comments")
                        .font(.headline)
                    Text(review.bodyValue)
                        .font(.body)
                }
            }
            .padding()
        }
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Displays a rating field with label and poop icons (non-interactive)
struct RatingDisplayRow: View {
    let label: String
    let rating: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .bold()
                .foregroundColor(.secondary)
            HStack {
                PoopsSelectionView(rating: .constant(rating))
                Spacer()
                Text("\(rating)/5")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ReviewDetailView(review: Review())
    }
}
