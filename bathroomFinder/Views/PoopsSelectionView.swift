//
//  PoopsSelectionView.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 1/17/24.
//

import SwiftUI

struct PoopsSelectionView: View {
    @Binding var rating: Int
    let highestRating = 5
    let unselected = Image("blankPoopEmoji")
    let selected = Image("poopEmoji")
    
    var body: some View {
        HStack {
            ForEach(1...highestRating, id: \.self) { number in
                showPoop(for: number)
                    .foregroundColor(number <= rating ? .brown : .black)
                    .onTapGesture {
                        rating = number
                    }
                    .padding(EdgeInsets(top: 0, leading: -8, bottom: 0, trailing: -8))
            }
            .font(.largeTitle)
        }
    }
    
    func showPoop(for number: Int) -> Image {
        number > rating ? unselected : selected
    }
}

#Preview {
    PoopsSelectionView(rating: .constant(4))
}
