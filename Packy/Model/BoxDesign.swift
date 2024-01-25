//
//  BoxDesign.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import Foundation

typealias BoxDesignResponse = [BoxDesign]

struct BoxDesign: Decodable, Equatable {
    let id: Int
    let sequence: Int
    let boxPartUrl: String
    let boxBottomUrl: String
    let boxFullUrl: String

    enum CodingKeys: String, CodingKey {
        case id, sequence
        case boxPartUrl = "boxPart"
        case boxBottomUrl = "boxBottom"
        case boxFullUrl = "boxFull"
    }
}

// MARK: - Mock

extension BoxDesign {
    static let mock: Self = .init(
        id: 0,
        sequence: 0,
        boxPartUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/box-part/box_part_1.png",
        boxBottomUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/box-bottom/bottom_1.png",
        boxFullUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/box-full/box_1.png"
    )
}

extension BoxDesignResponse {
    static let mock: Self = (1...4).map {
        .init(
            id: $0,
            sequence: $0,
            boxPartUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/box-part/box_part_1.png",
            boxBottomUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/box-bottom/bottom_\($0).png",
            boxFullUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/box-full/box_\($0).png"
        )
    }
}
