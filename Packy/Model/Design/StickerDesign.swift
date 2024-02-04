//
//  StickerDesign.swift
//  Packy
//
//  Created by Mason Kim on 1/26/24.
//

import Foundation

// MARK: - Sticker Design Response

struct StickerDesignResponse: Equatable, Decodable {
    let contents: [StickerDesign]
    /// 페이지네이션 관련
    let isFirstPage: Bool
    let isLastPage: Bool

    enum CodingKeys: String, CodingKey {
        case contents = "content"
        case isFirstPage = "first"
        case isLastPage = "last"
    }
}

extension StickerDesignResponse {
    func sorted() -> Self {
        .init(contents: contents.sorted(by: \.sequence), isFirstPage: isFirstPage, isLastPage: isLastPage)
    }
}


// MARK: - Sticker Design

struct StickerDesign: Equatable, Decodable {
    let id: Int
    let sequence: Int
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id, sequence
        case imageUrl = "imgUrl"
    }
}

// MARK: - Mock Data

extension StickerDesignResponse {
    static var mock: Self {
        .init(
            contents: (0...10).map {
                StickerDesign(id: Int.random(in: 0...1000), sequence: $0, imageUrl: Constants.mockImageUrl)
            },
            isFirstPage: true,
            isLastPage: false
        )

    }
}
