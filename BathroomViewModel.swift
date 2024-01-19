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
        let db = Firestore.firestore()      //ignore error
        
        
        if let id = bathroom.id { // bathroom already saved/exists
            do {
                try await db.collection("bathrooms").document(id).setData(bathroom.dictionary) //is bathrooms the right name?
                print("bathroom already exists, just updating: data updated successfully, bathroomVM")
                return true
            } catch {
                print("could not update data in 'bathrooms' \(error.localizedDescription)")
                return false
            }
            
        } else { //new bathroom to add
            do {
                let documentRef = try await db.collection("bathrooms").addDocument(data: bathroom.dictionary)
                print(documentRef)
                print(documentRef.documentID)
                self.bathroom = bathroom
                self.bathroom.id = documentRef.documentID
                print("created new bathroom: data updated successfully in bathroom view model")
                print("new bathrrom id is \(self.bathroom.id)")
                return true
            } catch {
                print("could not create a bew bathroom in 'bathrooms' \(error.localizedDescription)")
                return false
            }
        }
        
        
    }
}
