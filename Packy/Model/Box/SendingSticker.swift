//
//  Sticker.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
//

import Foundation

struct SendingSticker: Encodable, Equatable {
    let id: Int
    let location: Int
}

// MARK: - Mock Data

extension SendingSticker {
    static var mock: Self {
        return SendingSticker(
            id: 1,
            location: 1
        )
    }
}
