//
//  Sticker.swift
//  Packy
//
//  Created by Mason Kim on 2/1/24.
//

import Foundation

struct Sticker: Decodable, Equatable {
    let imgUrl: String
    let location: Int
}

// MARK: - Mock Data

extension Sticker {
    static var mock: Self {
        return Sticker(
            imgUrl: Constants.mockImageUrl,
            location: 1
        )
    }
}

extension [Sticker] {
    static var mock: Self {
        return [
            Sticker(
                imgUrl: Constants.mockImageUrl,
                location: 0
            ),
            Sticker(
                imgUrl: Constants.mockImageUrl,
                location: 1
            ),
        ]
    }
}
