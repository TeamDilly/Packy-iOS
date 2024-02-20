//
//  SentReceivedGiftBox.swift
//  Packy
//
//  Created by Mason Kim on 2/7/24.
//

import Foundation

struct SentReceivedGiftBoxPageData: Hashable {
    let giftBoxes: [SentReceivedGiftBox]
    let isFirstPage: Bool
    let isLastPage: Bool
}

/// 주고받은 선물박스 정보
struct SentReceivedGiftBox: Hashable, Identifiable {
    let id: Int
    let type: SentReceivedType
    let sender: String
    let receiver: String
    let name: String
    let giftBoxDate: Date
    let boxImageUrl: String

    var senderReceiverInfo: String {
        switch type {
        case .sent:     return "To. \(receiver)"
        case .received: return "From. \(sender)"
        }
    }
}

enum SentReceivedType: String {
    case sent
    case received
}

// MARK: - Mock Data

extension SentReceivedGiftBox {
    static let mock: Self = .init(
        id: 0,
        type: .received,
        sender: "moon",
        receiver: "mason",
        name: "gift for ya",
        giftBoxDate: .init(),
        boxImageUrl: Constants.mockImageUrl
    )
}
