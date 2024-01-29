//
//  LetterElementView.swift
//  Packy
//
//  Created by Mason Kim on 1/29/24.
//

import SwiftUI
import Kingfisher

struct LetterElementView: View {
    let input: BoxStartGuideFeature.LetterInput
    let screenWidth: CGFloat
    var action: () -> Void = {}

    private let element = BoxElementShape.letter
    private let letterContentWidthRatio: CGFloat = 160 / 180
    private let letterContentHeightRatio: CGFloat = 130 / 150

    var body: some View {
        let size = element.size(fromScreenWidth: screenWidth)
        let letterContentWidth = letterContentWidthRatio * size.width
        let letterContentHeight = letterContentHeightRatio * size.height
        let spacing = letterContentWidth * (20 / 160)

        Button {
            HapticManager.shared.fireFeedback(.soft)
            action()
        } label: {
            ZStack {
                Text(input.letter)
                    .packyFont(.body6)
                    .foregroundStyle(.gray900)
                    .padding(8)
                    .frame(width: letterContentWidth, height: letterContentHeight, alignment: .top)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white)
                    )

                if let imageUrl = input.selectedLetterDesign?.imageUrl {
                    KFImage(URL(string: imageUrl))
                        .resizable()
                        .frame(width: letterContentWidth, height: letterContentHeight, alignment: .top)
                        .offset(x: spacing, y: spacing)
                }
            }
            .frame(width: size.width, height: size.height)
            .rotationEffect(.degrees(element.rotationDegree))
        }
        .buttonStyle(.bouncy)
    }
}
