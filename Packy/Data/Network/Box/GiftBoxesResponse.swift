//
//  GiftBoxesResponse.swift
//  Packy
//
//  Created by Mason Kim on 2/6/24.
//

import Foundation

// MARK: - Response

struct GiftBoxesResponse: Decodable {
    let contents: [GiftBoxesResponseContent]
    let isFirstPage: Bool
    let isLastPage: Bool

    enum CodingKeys: String, CodingKey {
        case contents = "content"
        case isFirstPage = "first"
        case isLastPage = "last"
    }
}

struct GiftBoxesResponseContent: Decodable {
    let id: Int
    let type: String
    let sender: String
    let receiver: String
    let name: String
    let giftBoxDate: String
    let boxNormal: String
}

// MARK: - Response To Domain

extension GiftBoxesResponse {
    func toDomian() -> SentReceivedGiftBoxPageData {
        .init(giftBoxes: contents.map { $0.toDomian() }, isFirstPage: isFirstPage, isLastPage: isLastPage)
    }
}

extension GiftBoxesResponseContent {
    func toDomian() -> SentReceivedGiftBox {
        .init(
            id: id,
            type: .init(rawValue: type) ?? .received,
            sender: sender,
            receiver: receiver,
            name: name,
            giftBoxDate: giftBoxDate.date(fromFormat: .serverDateTime),
            boxImageUrl: boxNormal
        )
    }
}
