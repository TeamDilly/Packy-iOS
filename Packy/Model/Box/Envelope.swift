//
//  Envelope.swift
//  Packy
//
//  Created by Mason Kim on 2/1/24.
//

import Foundation

struct Envelope: Decodable, Equatable {
    let imgUrl: String
    let borderColorCode: String
}

extension Envelope {
    static let mock: Self = .init(
        imgUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/envelope/envelope_1.png",
        borderColorCode: "ED76A5"
    )
}
