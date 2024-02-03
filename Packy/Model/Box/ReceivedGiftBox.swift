//
//  ReceivedGiftBox.swift
//  Packy
//
//  Created by Mason Kim on 2/1/24.
//

import Foundation

struct ReceivedGiftBox: Decodable, Equatable {
    let name: String
    let senderName: String
    let receiverName: String
    let box: ReceivedBox
    let envelope: Envelope
    let letterContent: String
    let youtubeUrl: String
    let photos: [Photo]
    let stickers: [Sticker]
    let gift: Gift?
}

// MARK: - Mock Data

extension ReceivedGiftBox {
    static let mock: Self = .init(
        name: "오늘을 위한 특별한 생일 선물",
        senderName: "제이",
        receiverName: "밀리밀리밀리",
        box: .mock,
        envelope: .mock,
        letterContent: "생일 축하해~",
        youtubeUrl: "https://www.youtube.com/watch?v=neaxGr8_trU",
        photos: [.mock],
        stickers: .mock,
        gift: .mock
    )
}
