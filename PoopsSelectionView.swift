//
//  PoopsSelectionView.swift
//  bathroomFinder
//
//  Created by Ben Oliver on 1/17/24.
//

import SwiftUI

struct PoopsSelectionView: View {
    @State var rating: Int // change this to @biding after layout is tested
    let highestRating = 5
    let unselected = Image(systemName: "star")
    let selected = Image(systemName: "star.fill")
    let font: Font = .largeTitle
    let fillColor: Color = .brown
    let emptyColor: Color = .black
    
    var body: some View {
        HStack {
            ForEach(1...highestRating, id: \.self) { number in
                showPoop(for: number)
                    .foregroundColor(number <= rating ? fillColor : emptyColor)
                    .onTapGesture {
                        rating = number
                    }
            }
            .font(font)
        }
    }
    func showPoop( for number: Int) -> Image {
        if number > rating {
            return unselected
        } else {
            return selected
        }
    }
}

#Preview {
    PoopsSelectionView(rating:4)
}
