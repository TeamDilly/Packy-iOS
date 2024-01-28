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
    let sequence: Int
    let youtubeUrl: String
    let title: String
    let hashtags: [String]
}

// MARK: - Mock

extension RecommendedMusicResponse {
    static let mock: Self = [
        .init(id: 0, sequence: 0, youtubeUrl: "https://www.youtube.com/watch?v=jG6RnLVX07I", title: "제목제목", hashtags: ["aa", "bb"]),
        .init(id: 1, sequence: 1, youtubeUrl: "https://www.youtube.com/watch?v=HwiT_CCnwts", title: "제목제목", hashtags: ["cc", "dd"]),
        .init(id: 2, sequence: 2, youtubeUrl: "https://www.youtube.com/watch?v=jG6RnLVX07I", title: "제목제목", hashtags: ["aa", "bb"]),
        .init(id: 3, sequence: 3, youtubeUrl: "https://www.youtube.com/watch?v=HwiT_CCnwts", title: "제목제목", hashtags: ["cc", "dd"])
    ]
}
