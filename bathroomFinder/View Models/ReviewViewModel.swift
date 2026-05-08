//
//  ReviewViewModel.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 1/19/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

extension Notification.Name {
    static let reviewSaved = Notification.Name("reviewSaved")
}

class ReviewViewModel: ObservableObject {
    @Published var review = Review()
    
    func saveReview(bathroom: Bathroom, review: Review) async -> Bool {
        let db = Firestore.firestore()
        
        guard let bathroomID = bathroom.id else {
            print("error bathroom.id = nil")
            return false
        }
        let collectionString = "bathrooms/\(bathroomID)/reviews"
        
        // Save the review
        if let id = review.id {
            do {
                try await db.collection(collectionString).document(id).setData(review.dictionary)
            } catch {
                print("could not update review: \(error.localizedDescription)")
                return false
            }
        } else {
            do {
                try await db.collection(collectionString).addDocument(data: review.dictionary)
            } catch {
                print("could not create review: \(error.localizedDescription)")
                return false
            }
        }
        
        // Recalculate average rating and update bathroom document
        await updateBathroomRating(bathroomID: bathroomID)
        
        // Notify MapView to refresh
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .reviewSaved, object: nil)
        }
        
        return true
    }
    
    private func updateBathroomRating(bathroomID: String) async {
        let db = Firestore.firestore()
        
        do {
            let snapshot = try await db.collection("bathrooms/\(bathroomID)/reviews").getDocuments()
            let reviews = snapshot.documents.compactMap { try? $0.data(as: Review.self) }
            
            guard !reviews.isEmpty else { return }
            
            let avg = reviews.map { $0.overallRating }.reduce(0, +) / Double(reviews.count)
            
            try await db.collection("bathrooms").document(bathroomID).updateData([
                "averageRating": avg,
                "reviewCount": reviews.count
            ])
        } catch {
            print("Error updating bathroom rating: \(error.localizedDescription)")
        }
    }
}
