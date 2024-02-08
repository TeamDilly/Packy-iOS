//
//  MusicElementView.swift
//  Packy
//
//  Created by Mason Kim on 1/29/24.
//

import SwiftUI
import YouTubePlayerKit

struct MusicElementView: View {
    let screenWidth: CGFloat
    var deleteAction: () -> Void
    var isPresentCloseButton: Bool = false

    @ObservedObject var youtubePlayer: YouTubePlayer

    init(
        player: YouTubePlayer,
        screenWidth: CGFloat,
        deleteAction: @escaping () -> Void = {},
        isPresentCloseButton: Bool = false
    ) {
        self.youtubePlayer = player
        self.screenWidth = screenWidth
        self.deleteAction = deleteAction
        self.isPresentCloseButton = isPresentCloseButton
    }

    private let element = BoxElementShape.music
    private var size: CGSize {
        element.size(fromScreenWidth: screenWidth)
    }

    var body: some View {
        YouTubePlayerView(youtubePlayer) { state in
            switch state {
            case .idle:
                PackyProgress()
            case .ready:
                EmptyView()
            case .error:
                Text("문제가 생겼어요")
                    .packyFont(.body1)
            }
        }
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
        .onAppear {
            youtubePlayer.play()
        }
    }
}
