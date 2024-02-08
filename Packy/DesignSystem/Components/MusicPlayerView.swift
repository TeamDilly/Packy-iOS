//
//  MusicPlayerView.swift
//  Packy
//
//  Created by Mason Kim on 1/12/24.
//

import SwiftUI
import YouTubePlayerKit

struct MusicPlayerView: View {
    let player: YouTubePlayer

    init(youtubeUrl: String, autoPlay: Bool = true) {
        self.player = .init(
            source: .url(youtubeUrl),
            configuration: .init(
                autoPlay: autoPlay,
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
