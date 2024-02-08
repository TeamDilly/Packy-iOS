//
//  PackyProgress.swift
//  Packy
//
//  Created by Mason Kim on 2/7/24.
//

import SwiftUI

struct PackyProgress: View {
    enum SizeType {
        case small
        case medium
    }

    var sizeType: SizeType = .small
    var color: Color = .black

    @State private var isSpinning: Bool = false

    var body: some View {
        image
            .renderingMode(.template)
            .foregroundStyle(color)
            .rotationEffect(.degrees(isSpinning ? 360 : 0))
            .onAppear {
                withAnimation(.linear(duration: 0.7).repeatForever(autoreverses: false)) {
                    isSpinning = true
                }
            }
    }

    var image: Image {
        switch sizeType {
        case .small:    return Image(.progressSmall)
        case .medium:   return Image(.progressMedium)
        }
    }
}

#Preview {
    PackyProgress()
}
