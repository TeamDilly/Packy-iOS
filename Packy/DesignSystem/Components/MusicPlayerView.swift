//
//  MusicPlayerView.swift
//  Packy
//
//  Created by Mason Kim on 1/12/24.
//

import SwiftUI
import YouTubePlayerKit

struct MusicPlayerView: View {
    @ObservedObject var youTubePlayer: YouTubePlayer

    var body: some View {
        YouTubePlayerView(self.youTubePlayer) { state in
            switch state {
            case .idle:
                ProgressView()
            case .ready:
                EmptyView()
            case .error(let error):
                Text(verbatim: "YouTube player couldn't be loaded")
            }
        }
        .task {
            Task {
                // Test
                try? await youTubePlayer.play()
                try? await Task.sleep(for: .seconds(2))
                try? await youTubePlayer.pause()
                try? await Task.sleep(for: .seconds(2))
                try? await youTubePlayer.play()
            }
        }
    }
}

#Preview {
    MusicPlayerView(youTubePlayer: "https://youtube.com/watch?v=psL_5RIBqnY")
}
