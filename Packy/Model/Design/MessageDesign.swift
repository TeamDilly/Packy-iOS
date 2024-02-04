//
//  MessageDesign.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import Foundation

typealias MessageDesignResponse = [MessageDesign]

struct MessageDesign: Decodable, Equatable {
    let id: Int
    let imageUrl: String
}

// MARK: - Mock

extension MessageDesignResponse {
    static let mock: Self =
    (0...3).map {
        .init(id: $0, imageUrl: Constants.mockImageUrl)
    }
}
