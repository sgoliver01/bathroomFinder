//
//  FavoritesView.swift
//  bathroomFinder
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    
    var body: some View {
        Group {
            if viewModel.favorites.isEmpty {
                VStack(spacing: 16) {
                    Text("💩")
                        .font(.system(size: 50))
                    Text("No favorites yet")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Text("Tap the ❤️ on a bathroom to save it here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.favorites) { bathroom in
                        NavigationLink {
                            BathroomDetailView(bathroom: bathroom)
                        } label: {
                            HStack(spacing: 12) {
                                Text("🚽")
                                    .font(.title2)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(bathroom.name)
                                        .font(.headline)
                                    Text(bathroom.address)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.removeFavorite(viewModel.favorites[index])
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favorites❤️")
        .onAppear {
            viewModel.fetchFavorites()
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
    }
}
