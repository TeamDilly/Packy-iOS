//
//  Envelope.swift
//  Packy
//
//  Created by Mason Kim on 2/1/24.
//

import Foundation

struct Envelope: Decodable, Equatable, Hashable {
    let imageUrl: String
    let borderColorCode: String
    let opacityPercent: Int
    var opacity: Double { Double(opacityPercent) / 100 }

    enum CodingKeys: String, CodingKey {
        case imageUrl = "imgUrl"
        case borderColorCode
        case opacityPercent = "opacity"
    }
}

extension Envelope: ColorFromServer {
    var colorHexCode: String { borderColorCode }
}

extension Envelope {
    static let mock: Self = .init(
        imageUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/envelope/envelope_1.png",
        borderColorCode: "ED76A5",
        opacityPercent: 30
    )
}
