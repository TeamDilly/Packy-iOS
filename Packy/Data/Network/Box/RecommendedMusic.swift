//
//  RecommendedMusic.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import Foundation

typealias RecommendedMusicResponse = [RecommendedMusic]

struct RecommendedMusic: Decodable, Equatable {
    let id: Int
    let youtubeUrl: String
    let hashtags: [String]
}

// MARK: - Mock

extension RecommendedMusicResponse {
    static let mock: Self = [
        .init(id: 0, youtubeUrl: "https://www.youtube.com/watch?v=jG6RnLVX07I", hashtags: ["aa", "bb"]),
        .init(id: 1, youtubeUrl: "https://www.youtube.com/watch?v=HwiT_CCnwts", hashtags: ["cc", "dd"]),
        .init(id: 2, youtubeUrl: "https://www.youtube.com/watch?v=jG6RnLVX07I", hashtags: ["aa", "bb"]),
        .init(id: 3, youtubeUrl: "https://www.youtube.com/watch?v=HwiT_CCnwts", hashtags: ["cc", "dd"])
    ]
}
