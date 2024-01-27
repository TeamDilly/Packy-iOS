//
//  GiftBox.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
//

import Foundation

struct GiftBox: Encodable, Equatable {
    var name: String
    let senderName: String
    let receiverName: String
    let boxId: Int
    let envelopeId: Int
    let letterContent: String
    let youtubeUrl: String
    let photos: [Photo]
    let gift: Gift?
    let stickers: [Sticker]
}

// MARK: - Mock Data

extension GiftBox {
    static var mock: Self {
        return .init(
            name: "오늘을 위한 특별한 생일 선물",
            senderName: "제이(보내는 사람)",
            receiverName: "제삼(받는 사람)",
            boxId: 1,
            envelopeId: 1,
            letterContent: "생일 축하해~",
            youtubeUrl: "https://www.youtube.com",
            photos: [Photo.mock],
            gift: Gift.mock,
            stickers: [Sticker.mock]
        )
    }
}
