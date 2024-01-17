//
//  ListView.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 1/17/24.
//

import Foundation
import SwiftUI
import Firebase

struct ListView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        List {
            Text("list items will go here")
        }
        .listStyle(.plain)
        .navigationBarBackButtonHidden()
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
                    //TODO: add item code here
                    
                } label: {
                    Image(systemName: "plus")
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
 
