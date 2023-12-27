//
//  RateView.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 12/26/23.
//

import SwiftUI

struct RateView: View {
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
                   
                    
                    Text("Rate a bathroom here")
                        .multilineTextAlignment(.center)
                }
            }
            
            
        }    }
}

#Preview {
    RateView()
}
