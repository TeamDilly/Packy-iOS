//
//  LetterDesign.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import Foundation

typealias LetterDesignResponse = [LetterDesign]

struct LetterDesign: Decodable, Equatable {
    let id: Int
    let sequence: Int
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id, sequence
        case imageUrl = "imgUrl"
    }
}

// MARK: - Mock

extension LetterDesignResponse {
    static let mock: Self = (1...4).map {
        .init(id: $0, sequence: $0, imageUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/envelope/envelope_\($0).png")
    }
}
