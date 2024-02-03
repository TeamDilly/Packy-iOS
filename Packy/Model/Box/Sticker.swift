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
            imgUrl: "https://picsum.photos/150",
            location: 1
        )
    }
}

extension [Sticker] {
    static var mock: Self {
        return [
            Sticker(
                imgUrl: "https://picsum.photos/150",
                location: 0
            ),
            Sticker(
                imgUrl: "https://picsum.photos/180",
                location: 1
            ),
        ]
    }
}
