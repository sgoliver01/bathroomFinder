//
//  HomeView.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 12/22/23.
//

import SwiftUI
import MapKit
import Firebase


struct HomeView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: Int
    @State private var showShareSheet = false
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                Map(initialPosition: .userLocation(fallback: .automatic))
                    .mapControls { MapUserLocationButton() }
                    .ignoresSafeArea()
                
                VStack {
                    Text("🚽 Bathroom Finder")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .padding(.top, 60)
                    
                    Spacer()
                    
                    Button {
                        selectedTab = 1
                    } label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Search nearby bathrooms")
                        }
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.gradient)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .padding(.horizontal, 40)
                    
                    Button {
                        showShareSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share app with a friend")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                    .padding(.bottom, 60)
                }
            }
            .toolbar {
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
                    .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareView()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView(selectedTab: .constant(0))
                .environmentObject(LocationManager())
        }
    }
}

