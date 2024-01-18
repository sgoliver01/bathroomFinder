//
//  ContentView.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 12/22/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift


struct HomeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messageString = "Bathroom Finder"
    
    var body: some View {
        
        NavigationStack {
            GeometryReader {geometry in
                ZStack {
                    Rectangle()
                        .fill(
                            Gradient(colors: [.white, Color("dullGray"), .black])
                        )
                        .opacity(0.5)
                        .ignoresSafeArea()
                    
                    VStack {
                        Text(messageString)
                            .foregroundColor(.blue)
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .minimumScaleFactor(0.5)
                            .padding()
                        //                            .italic()
                            .underline()
                            .multilineTextAlignment(.center)
                        //                            .background(.green)
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: .top)
                            .padding(.bottom, 40)
                        
                        ZStack {
                            Image(.map)
                                .resizable()
                                .frame(width: geometry.size.width * 2/3, height: geometry.size.height * 3/5, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .scaledToFill()
                                .padding(10.0)
                                .background(.dullGray)
                                .foregroundStyle(.tint)
                                .padding(20)
                            
                            
                            VStack {
                                NavigationLink {
                                    MapView()
                                } label: {
                                    
                                    Text("Search nearby bathrooms")
                                }
                                .buttonStyle(.bordered)
                                .frame(width: 200)
                                .padding(5)
                                .font(.title3)
                                .fontWeight(.black)
                                .background(.gray)
                                .opacity(0.7)
                                .cornerRadius(10)
                                //can use navigationBarBackButtonHidden to remove back button and use @Environment(.\dismiss) instead
                                
                                
                            }
                        }
                        
                        
                        VStack {
                            Divider()
                                .background(.black)
                                .padding(.top, 50.0)
                                .frame(width: geometry.size.width, alignment: .bottom)
                            
                            NavigationLink {
                                ReviewView(bathroom: Bathroom(), review: Review())
                            } label: {
                                Text("Rate a Bathroom")
                            }
                            //                            .buttonStyle(.borderedProminent)
                            //                            .frame(width: 200, height: 50, alignment: .bottom)
                            //
                            
                        }
                        
                        
                    }
                }
                
            }
        }
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
        }
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView() //the location doesnt show in live preview - use simulator
                .environmentObject(LocationManager())
        }
    }
}
//                                    Button("Find a Bathroom")
////                                        //action performed when button is pressed
////                                        if messageString == "Bathroom Finder" {
////                                            messageString = "Nearby Bathrooms"
////                                        }
////
////                                        else {
////                                            messageString = "Bathroom Finder"
////                                        }
////                                    }
//                                    .frame(width: 200)
//                                    .padding(5)
//                                    .buttonStyle(.bordered)
//                                    .font(.title3)
//                                    .fontWeight(.black)
//                                    .background(.gray)
//                                    .opacity(0.7)
//                                    .cornerRadius(10)



