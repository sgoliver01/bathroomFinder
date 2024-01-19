//
//  ListView.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 1/17/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct ListView: View {
    @FirestoreQuery(collectionPath: "bathrooms") var bathrooms: [Bathroom]
    @State private var sheetIsPresented = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List(bathrooms) { bathroom in
                NavigationLink {
                    BathroomDetailView(bathroom: bathroom)
                } label: {
                    Text(bathroom.name)
                        .font(.title2)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Saved Bathrooms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign out") {
                        do {
                            try Auth.auth().signOut()
                            print("logout successful")
                            dismiss()
                        } catch {
                            print("error: couldnt sign out")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        sheetIsPresented.toggle()
                        
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $sheetIsPresented) {
                NavigationStack {
                    BathroomDetailView(bathroom: Bathroom())
                }
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ListView()
        }
    }
}

