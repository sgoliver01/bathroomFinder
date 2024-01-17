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
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray.opacity(0.5), lineWidth: 2)
                        }
                    }
                    .padding(.bottom)
                    
                    VStack (alignment: .leading) {
                        Text("Review Title:")
                            .bold()
                        
                        TextField("title", text: $review.title)
                            .textFieldStyle(.roundedBorder)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray.opacity(0.5), lineWidth: 2)
                            }
                        Text("Review")
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
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            //TODO: Add Save code her
                            dismiss()
                        }
                    }
                })
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
