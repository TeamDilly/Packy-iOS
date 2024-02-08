//
//  LetterDesign.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import Foundation
import SwiftUI

typealias LetterDesignResponse = [LetterDesign]

struct LetterDesign: Decodable, Equatable {
    let id: Int
    let sequence: Int
    /// hex Color 값
    let envelopeColor: ColorData
    let letterColor: ColorData
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case sequence
        case envelopeColor  = "envelope"
        case letterColor    = "letter"
        case imageUrl       = "imgUrl"
    }
}

extension LetterDesign {
    struct ColorData: Decodable, Equatable {
        let borderColorCode: String
        let opacityPercent: Int
        var opacity: Double { Double(opacityPercent) / 100 }

        enum CodingKeys: String, CodingKey {
            case borderColorCode
            case opacityPercent = "opacity"
        }
    }
}

extension LetterDesign.ColorData: ColorFromServer {
    var colorHexCode: String { borderColorCode }
}


// MARK: - Mock

extension LetterDesignResponse {
    static let mock: Self = (1...4).map {
        .init(
            id: $0,
            sequence: $0,
            envelopeColor: .init(borderColorCode: "ED76A5", opacityPercent: 30),
            letterColor: .init(borderColorCode: "ED76A5", opacityPercent: 30),
            imageUrl: ""
        )
    }
}
