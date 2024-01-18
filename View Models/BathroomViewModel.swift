//
//  BathroomViewModel.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 1/18/24.
//

import Foundation
import FirebaseFirestore

class BathroomViewModel: ObservableObject {
    @Published var bathroom = Bathroom()
    
    func saveBathroom(bathroom: Bathroom) async -> Bool {
        let db = Firestore.firestore()      //ignore error
        
        
        if let id = bathroom.id { // bathroom already saved/exists
            do {
                try await db.collection("bathrooms").document(id).setData(bathroom.dictionary) //is bathrooms the right name?
                print("data updated successfully")
                return true
            } catch {
                print("could not update data in 'bathrooms' \(error.localizedDescription)")
                return false
            }
            
        } else { //new bathroom to add
            do {
                try await db.collection("bathrooms").addDocument(data: bathroom.dictionary)
                print("data updated successfully")
                return true
            } catch {
                print("could not create a bew bathroom in 'bathrooms' \(error.localizedDescription)")
                return false
            }
        }
        
        
    }
}
