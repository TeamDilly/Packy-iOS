//
//  SendGiftBox.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
//

import Foundation

/// 이미지들을 업로드한, 실제로 서버에 통신하는 데이터
struct SendingGiftBox: Encodable, Equatable {
    var name: String
    let senderName: String
    let receiverName: String
    var boxId: Int?
    let envelopeId: Int
    let letterContent: String
    let youtubeUrl: String
    var photos: [Photo]
    var gift: Gift?
    let stickers: [SendingSticker]
}

/// 서버에 이미지를 업로드하기 전의 data
struct SendingGiftBoxRawData: Equatable {
    var name: String
    let senderName: String
    let receiverName: String
    var boxId: Int?
    let envelopeId: Int
    let letterContent: String
    let youtubeUrl: String
    let photos: [PhotoRawData]
    let gift: GiftRawData?
    let stickers: [SendingSticker]
}

// MARK: - Mock Data

extension SendingGiftBox {
    static var mock: Self {
        return .init(
            name: "오늘을 위한 특별한 생일 선물",
            senderName: "제이(보내는 사람)",
            receiverName: "제삼(받는 사람)",
            boxId: 1,
            envelopeId: 1,
            letterContent: "생일 축하해~",
            youtubeUrl: "https://www.youtube.com/watch?v=E13YdUGCq8w&list=RDYsGfmziPJ_Y&index=3",
            photos: [Photo.mock],
            gift: Gift.mock,
            stickers: [SendingSticker.mock]
        )
    }
}

extension SendingGiftBoxRawData {
    static var mock: Self {
        return .init(
            name: "오늘을 위한 특별한 생일 선물",
            senderName: "제이(보내는 사람)",
            receiverName: "제삼(받는 사람)",
            boxId: 1,
            envelopeId: 1,
            letterContent: "생일 축하해~",
            youtubeUrl: "https://www.youtube.com/watch?v=E13YdUGCq8w&list=RDYsGfmziPJ_Y&index=3",
            photos: [PhotoRawData.mock],
            gift: .mock,
            stickers: [SendingSticker.mock]
        )
    }
}
