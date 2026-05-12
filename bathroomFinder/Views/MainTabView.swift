//
//  MainTabView.swift
//  bathroomFinder
//
//  Created by Oliver, Sarah on 1/28/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var bathroomCache = BathroomCache()
    
    var body: some View {
        
        ZStack {
                    TabView(selection: $selectedTab) {
                        NavigationStack {
                            HomeView(selectedTab: $selectedTab)
                        }
                        .tabItem {
                            Image(systemName: "house")
                            Text("Home")
                        }
                        .tag(0)

                        MapView(bathroom: Bathroom())
                            .tabItem {
                                Image(systemName: "map.circle")
                                Text("Find")
                            }
                            .tag(1)

                        NavigationStack {
                            ReviewView(bathroom: Bathroom(), review: Review())
                        }
                        .tabItem {
                            Image(systemName: "pencil")
                            Text("Rate")
                        }
                        .tag(2)

                        NavigationStack {
                            FavoritesView()
                        }
                        .tabItem {
                            Image(systemName: "heart")
                            Text("Favorites")
                        }
                        .tag(3)

                        ProfileView()
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                Text("Profile")
                            }
                            .tag(4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .edgesIgnoringSafeArea(.all)
                .environmentObject(bathroomCache)
            
    
    }
}

#Preview {
    MainTabView()
}
