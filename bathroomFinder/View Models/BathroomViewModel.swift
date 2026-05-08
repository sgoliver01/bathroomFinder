//
//  BathroomViewModel.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 1/18/24.
//

import Foundation
import FirebaseFirestore

@MainActor //makes it so that you can change the UI outside of the main thread

class BathroomViewModel: ObservableObject {
    @Published var bathroom = Bathroom()
    
    func saveBathroom(bathroom: Bathroom) async -> Bool {
        let db = Firestore.firestore()
        
        if let id = bathroom.id { // bathroom already saved/exists
            do {
                try await db.collection("bathrooms").document(id).setData(bathroom.dictionary)
                print("bathroom already exists, just updating: data updated successfully, bathroomVM")
                self.bathroom = bathroom
                return true
            } catch {
                print("could not update data in 'bathrooms' \(error.localizedDescription)")
                return false
            }
            
        } else {
            // Check if a bathroom with same name and coordinates already exists
            do {
                let snapshot = try await db.collection("bathrooms")
                    .whereField("name", isEqualTo: bathroom.name)
                    .whereField("latitude", isEqualTo: bathroom.latitude)
                    .getDocuments()
                
                if let existingDoc = snapshot.documents.first {
                    // Found existing bathroom — use it
                    self.bathroom = bathroom
                    self.bathroom.id = existingDoc.documentID
                    print("found existing bathroom with id: \(existingDoc.documentID)")
                    return true
                }
            } catch {
                print("error searching for existing bathroom: \(error.localizedDescription)")
            }
            
            // No existing match — create new
            do {
                let documentRef = try await db.collection("bathrooms").addDocument(data: bathroom.dictionary)
                self.bathroom = bathroom
                self.bathroom.id = documentRef.documentID
                print("created new bathroom with id: \(self.bathroom.id ?? "")")
                return true
            } catch {
                print("could not create a new bathroom in 'bathrooms' \(error.localizedDescription)")
                return false
            }
        }
    }
}
