//
//  MusicArchiveData.swift
//  Packy
//
//  Created by Mason Kim on 2/18/24.
//

import Foundation

struct MusicArchivePageData: Decodable, Hashable {
    let first: Bool
    let last: Bool
    let content: [MusicArchiveData]
}

struct MusicArchiveData: Decodable, Hashable, Identifiable {
    let id: Int
    let youtubeUrl: String
}

// MARK: - Mock Data

extension MusicArchivePageData {
    static let mock: Self = .init(
        first: true,
        last: true,
        content: [
            MusicArchiveData(id: 1, youtubeUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"),
            MusicArchiveData(id: 2, youtubeUrl: "https://www.youtube.com/watch?v=C0DPdy98e4c")
        ]
    )
}
