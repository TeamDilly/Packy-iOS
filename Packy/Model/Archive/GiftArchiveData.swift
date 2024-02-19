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
    let giftBoxId: Int
    let gift: Gift

    var id: Int { giftBoxId }
}

// MARK: - Mock Data

extension GiftArchivePageData {
    static let mock: Self = .init(
        first: true,
        last: true,
        content: (0...10).map {
            GiftArchiveData(giftBoxId: $0, gift: Gift(type: "photo", url: Constants.mockImageUrl))
        }
    )
}
