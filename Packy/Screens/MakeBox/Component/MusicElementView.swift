//
//  MusicElementView.swift
//  Packy
//
//  Created by Mason Kim on 1/29/24.
//

import SwiftUI

struct MusicElementView: View {
    var youtubeUrl: String
    let screenWidth: CGFloat
    var deleteAction: () -> Void
    var isPresentCloseButton: Bool = false

    init(
        youtubeUrl: String,
        screenWidth: CGFloat,
        deleteAction: @escaping () -> Void = {},
        isPresentCloseButton: Bool = false
    ) {
        self.youtubeUrl = youtubeUrl
        self.screenWidth = screenWidth
        self.deleteAction = deleteAction
        self.isPresentCloseButton = isPresentCloseButton
    }

    private let element = BoxElementShape.music
    private var size: CGSize {
        element.size(fromScreenWidth: screenWidth)
    }

    var body: some View {
        MusicPlayerView(youtubeUrl: youtubeUrl)
            .frame(width: size.width, height: size.height)
            .mask(RoundedRectangle(cornerRadius: 8))
            .if(isPresentCloseButton) {
                $0.overlay(alignment: .topTrailing) {
                    CloseButton(sizeType: .medium, colorType: .light) {
                        deleteAction()
                    }
                    .offset(x: 4, y: -4)
                }
            }
    }
}
