//
//  MusicPlayerView.swift
//  Packy
//
//  Created by Mason Kim on 1/12/24.
//

import SwiftUI
import YouTubePlayerKit

struct MusicPlayerView: View {
    @ObservedObject var player: YouTubePlayer

    init(youtubeUrl: String) {
        self.player = .init(stringLiteral: youtubeUrl)
        self.player.update(
            configuration: .init(
                autoPlay: true,
                showCaptions: false,
                showControls: false,
                showAnnotations: false
            )
        )
    }

    var body: some View {
        YouTubePlayerView(player) { state in
            switch state {
            case .idle:
                PackyProgress(color: .white)
            case .ready:
                EmptyView()
            case .error:
                Text("문제가 생겼어요").packyFont(.body1)
            }
        }
    }
}

#Preview {
    MusicPlayerView(youtubeUrl: "https://www.youtube.com/watch?v=neaxGr8_trU")
        .aspectRatio(16 / 9, contentMode: .fit)
        .padding()
}
