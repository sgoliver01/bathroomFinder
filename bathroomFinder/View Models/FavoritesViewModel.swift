//
//  FavoritesViewModel.swift
//  bathroomFinder
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Bathroom] = []
    @Published var favoriteIds: Set<String> = []
    
    private var db = Firestore.firestore()
    
    var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    func fetchFavorites() {
        guard let userId = userId else { return }
        
        db.collection("users").document(userId).collection("favorites")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching favorites: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                
                let ids = documents.compactMap { $0.documentID }
                self.favoriteIds = Set(ids)
                
                // Fetch full bathroom objects
                self.favorites = []
                for id in ids {
                    self.db.collection("bathrooms").document(id).getDocument { doc, error in
                        if let doc = doc, doc.exists,
                           let bathroom = try? doc.data(as: Bathroom.self) {
                            DispatchQueue.main.async {
                                if !self.favorites.contains(where: { $0.id == bathroom.id }) {
                                    self.favorites.append(bathroom)
                                }
                            }
                        }
                    }
                }
            }
    }
    
    func addFavorite(_ bathroom: Bathroom) {
        guard let userId = userId, let bathroomId = bathroom.id else { return }
        
        db.collection("users").document(userId).collection("favorites").document(bathroomId)
            .setData(["addedAt": Timestamp()])
    }
    
    func removeFavorite(_ bathroom: Bathroom) {
        guard let userId = userId, let bathroomId = bathroom.id else { return }
        
        db.collection("users").document(userId).collection("favorites").document(bathroomId)
            .delete()
    }
    
    func isFavorite(_ bathroom: Bathroom) -> Bool {
        guard let id = bathroom.id else { return false }
        return favoriteIds.contains(id)
    }
}
