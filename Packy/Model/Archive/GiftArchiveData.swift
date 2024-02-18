//
//  GiftArchiveData.swift
//  Packy
//
//  Created by Mason Kim on 2/18/24.
//

import Foundation

struct GiftArchivePageData: Decodable, Hashable {
    let first: Bool
    let last: Bool
    let content: [GiftArchiveData]
}

struct GiftArchiveData: Decodable, Hashable, Identifiable {
    let id: Int
    let gift: Gift
}

// MARK: - Mock Data

extension GiftArchivePageData {
    static let mock: Self = .init(
        first: true,
        last: true,
        content: [
            GiftArchiveData(id: 1, gift: Gift(type: "photo", url: "https://www.example.com/photo1.jpg")),
            GiftArchiveData(id: 2, gift: Gift(type: "video", url: "https://www.example.com/video1.mp4"))
        ]
    )
}
