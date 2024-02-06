//
//  SentReceivedGiftBox.swift
//  Packy
//
//  Created by Mason Kim on 2/7/24.
//

import Foundation

/// 주고받은 선물박스 정보
struct SentReceivedGiftBox: Equatable {
    let id: Int
    let sender: String
    let receiver: String
    let name: String
    let giftBoxDate: Date
    let boxImageUrl: String
}

// MARK: - Mock Data

extension SentReceivedGiftBox {
    static let mock: Self = .init(
        id: 0,
        sender: "moon",
        receiver: "mason",
        name: "gift for ya",
        giftBoxDate: .init(),
        boxImageUrl: Constants.mockImageUrl
    )
}
