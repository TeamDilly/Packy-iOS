//
//  PopupGiftBox.swift
//  Packy
//
//  Created by Mason Kim on 2/22/24.
//

import Foundation

/// 화면 진입 시, 팝업 형태로 띄워줄 선물 박스 정보
struct PopupGiftBox: Decodable, Hashable {
    let giftBoxId: Int
    let name: String
    let senderName: String
    let normalImgUrl: String
}

// MARK: - Mock Data

extension PopupGiftBox {
    static let mock: Self = .init(
        giftBoxId: 93,
        name: "Hello!",
        senderName: "Mason",
        normalImgUrl: Constants.mockImageUrl
    )
}
