//
//  StickerDesign.swift
//  Packy
//
//  Created by Mason Kim on 1/26/24.
//

import Foundation

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

struct StickerDesign: Equatable, Decodable {
    let id: Int
    let sequence: Int
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id, sequence
        case imageUrl = "imgUrl"
    }
}

extension StickerDesignResponse {
    static var mock: Self {
        .init(
            contents: (0...10).map {
                StickerDesign(id: Int.random(in: 0...1000), sequence: $0, imageUrl: "https://picsum.photos/200")
            },
            isFirstPage: true,
            isLastPage: false
        )

    }
}