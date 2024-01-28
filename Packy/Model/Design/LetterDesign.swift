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
    let borderColorCode: String
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id, sequence, borderColorCode
        case imageUrl = "imgUrl"
    }
}

extension LetterDesign {
    var borderColor: Color {
        Color(hexString: borderColorCode)
    }
}

// MARK: - Mock

extension LetterDesignResponse {
    static let mock: Self = (1...4).map {
        .init(id: $0, sequence: $0, borderColorCode: "ED76A5", imageUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/envelope/envelope_\($0).png")
    }
}
