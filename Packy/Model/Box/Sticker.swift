//
//  Sticker.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
//

import Foundation

struct Sticker: Encodable, Equatable {
    let id: Int
    let location: Int
}

// MARK: - Mock Data

extension Sticker {
    static var mock: Self {
        return Sticker(
            id: 1,
            location: 1
        )
    }
}
