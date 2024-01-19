//
//  RateView.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 12/26/23.
//

import SwiftUI

struct ReviewView: View {
    @State var bathroom: Bathroom
    @State var review: Review
    @State private var showPlaceLookupSheet = false
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        GeometryReader {geometry in
            
            ZStack {
                Rectangle()
                    .fill(
                        Gradient(colors: [.white, Color("dullGray"), .black])
                    )
                    .opacity(0.5)
                    .ignoresSafeArea()
                
                
                VStack {
                    
                    VStack (alignment: .leading) {
                        Text(bathroom.name)
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                        
                        Text(bathroom.address)
                            .padding(.bottom)
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Click to rate: ")
                        .font(.title2)
                        .bold()
                    HStack {
                        PoopsSelectionView(rating: review.rating)
                        //                            .overlay {
                        //                                RoundedRectangle(cornerRadius: 5)
                        //                                    .stroke(.gray.opacity(0.5), lineWidth: 2)
                        //                        }
                    }
                    .padding([.leading, .bottom, .trailing], 10.0)
                    
                    VStack (alignment: .leading) {
                        //Ease of use
                        Text("Ease of Use")
                            .bold()
                        
                        TextField("review", text: $review.easeOfUse, axis: .vertical)
                            .padding(.horizontal, 6)
                            .frame(maxHeight: .infinity, alignment:. topLeading)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray.opacity(0.5), lineWidth: 2)
                            }
                        
                        //Easy to find
                        Text("Easy to find")
                            .bold()
                        
                        TextField("review", text: $review.easyToFind, axis: .vertical)
                            .padding(.horizontal, 6)
                            .frame(maxHeight: .infinity, alignment:. topLeading)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray.opacity(0.5), lineWidth: 2)
                            }
                        
                        //long wait time?
                        Text("Wait Time")
                            .bold()
                        
                        TextField("Wait time", text: $review.line, axis: .vertical)
                            .padding(.horizontal, 6)
                            .frame(maxHeight: .infinity, alignment:. topLeading)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray.opacity(0.5), lineWidth: 2)
                            }
                        
                        //toilet paper
                        Text("Toilet Paper")
                            .bold()
                        
                        TextField("toilet paper", text: $review.toiletPaper, axis: .vertical)
                            .padding(.horizontal, 6)
                            .frame(maxHeight: .infinity, alignment:. topLeading)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray.opacity(0.5), lineWidth: 2)
                            }
                        //cleanliness
                        Text("Cleanliness")
                            .bold()
                        
                        TextField("Cleanliness", text: $review.cleanliness, axis: .vertical)
                            .padding(.horizontal, 6)
                            .frame(maxHeight: .infinity, alignment:. topLeading)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray.opacity(0.5), lineWidth: 2)
                            }
                        
                        
                        //full review
                        Text("Additional Comments")
                            .bold()
                        
                        TextField("review", text: $review.body, axis: .vertical)
                            .padding(.horizontal, 6)
                            .frame(maxHeight: .infinity, alignment:. topLeading)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray.opacity(0.5), lineWidth: 2)
                            }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .toolbar(content: {
//                    ToolbarItem(placement: .cancellationAction) {
//                        Button("Cancel") {
//                            dismiss()
//                        }
//                    }
                   
                        
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        
                        Button {
                            showPlaceLookupSheet.toggle()
                        } label: {
                            Image(systemName: "magnifyingglass")
                            Text("Lookup Place")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            //TODO: Add Save code her
                            dismiss()
                        }
                    }
                })
                .sheet(isPresented: $showPlaceLookupSheet) {
                    PlaceLookupView(bathroom: $bathroom)
                }
            }
            
            
        }    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReviewView(bathroom: Bathroom(name: "Shake Shack", address: "49 Boylston St., Chestnut Hill, MA 02467"), review: Review())
        }
    }
}
