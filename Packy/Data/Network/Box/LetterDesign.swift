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
    let letterPaperUrl: String
    let envelopeUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case letterPaperUrl = "letterPaper"
        case envelopeUrl = "envelope"
    }
}

// MARK: - Mock

extension LetterDesignResponse {
    static let mock: Self = [
        .init(id: 0, letterPaperUrl: "https://picsum.photos/200", envelopeUrl: "https://picsum.photos/300"),
        .init(id: 1, letterPaperUrl: "https://picsum.photos/200", envelopeUrl: "https://picsum.photos/300"),
        .init(id: 2, letterPaperUrl: "https://picsum.photos/200", envelopeUrl: "https://picsum.photos/300"),
        .init(id: 3, letterPaperUrl: "https://picsum.photos/200", envelopeUrl: "https://picsum.photos/300")
    ]
}
