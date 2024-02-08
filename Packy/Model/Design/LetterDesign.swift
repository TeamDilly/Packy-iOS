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
    static let mock: Self = [
        .init(
            id: 1,
            sequence: 1,
            envelopeColor: .init(borderColorCode: "3C3775", opacityPercent: 30),
            letterColor: .init(borderColorCode: "6B60E9", opacityPercent: 30),
            imageUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/envelope/envelope_1.png"
        ),
        .init(
            id: 2,
            sequence: 2,
            envelopeColor: .init(borderColorCode: "3F5896", opacityPercent: 30),
            letterColor: .init(borderColorCode: "6C8AD3", opacityPercent: 30),
            imageUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/envelope/envelope_2.png"
        ),
        .init(
            id: 3,
            sequence: 3,
            envelopeColor: .init(borderColorCode: "ED76A5", opacityPercent: 30),
            letterColor: .init(borderColorCode: "ED76A5", opacityPercent: 30),
            imageUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/envelope/envelope_3.png"
        ),
        .init(
            id: 4,
            sequence: 4,
            envelopeColor: .init(borderColorCode: "3C3775", opacityPercent: 30),
            letterColor: .init(borderColorCode: "6B60E9", opacityPercent: 30),
            imageUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/envelope/envelope_1.png"
        ),
        .init(
            id: 5,
            sequence: 5,
            envelopeColor: .init(borderColorCode: "3F5896", opacityPercent: 30),
            letterColor: .init(borderColorCode: "6C8AD3", opacityPercent: 30),
            imageUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/envelope/envelope_2.png"
        )
    ]
}
