//
//  ReviewViewModel.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 1/19/24.
//

import Foundation
import FirebaseFirestore

class ReviewViewModel: ObservableObject {
    @Published var review = Review()
    
    func saveReview(bathroom: Bathroom, review: Review) async -> Bool {
        let db = Firestore.firestore()      //ignore error
        
        guard let bathroomID = bathroom.id else {
            print("error bathroom.id = nil")
            return false
        }
        let collectionString = "bathrooms/\(bathroomID)/reviews"
        
        if let id = review.id { // review already saved/exists
            do {
                try await db.collection(collectionString).document(id).setData(review.dictionary) //is bathrooms the right name?
                print("review updated successfully")
                return true
            } catch {
                print("could not update data in 'reviews' \(error.localizedDescription)")
                return false
            }
            
        } else { //new review to add
            do {
                try await db.collection(collectionString).addDocument(data: review.dictionary)
                print("bathroom.id \(bathroom.id)")
                print("new review is \(review)")
                print("making a new review")
                return true
            } catch {
                print("could not create a bew review in 'reviews' \(error.localizedDescription)")
                return false
            }
        }
        
        
    }
}
