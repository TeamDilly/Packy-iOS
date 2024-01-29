//
//  StickerElementView.swift
//  Packy
//
//  Created by Mason Kim on 1/29/24.
//

import SwiftUI
import Kingfisher

struct StickerElementView: View {
    let stickerType: BoxElementShape
    let stickerURL: String
    let screenWidth: CGFloat
    var action: () -> Void = {}

    private var size: CGSize {
        stickerType.size(fromScreenWidth: screenWidth)
    }

    var body: some View {
        Button {
            HapticManager.shared.fireFeedback(.soft)
            action()
        } label: {
            KFImage(URL(string: stickerURL))
                .placeholder {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                .scaleToFillFrame(width: size.width, height: size.height)
                .rotationEffect(.degrees(stickerType.rotationDegree))
        }
    }
}
