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
    let boxFullUrl: String
    let boxPartUrl: String
    let boxBottomUrl: String

    enum CodingKeys: String, CodingKey {
        case id, sequence
        case boxFullUrl = "boxFull"
        case boxPartUrl = "boxPart"
        case boxBottomUrl = "boxBottom"
    }
}

// MARK: - Mock

extension BoxDesign {
    static let mock: Self = .init(
        id: 0,
        sequence: 0,
        boxFullUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/box-full/box_1.png",
        boxPartUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/box-part/box_part_1.png",
        boxBottomUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/box-bottom/bottom_1.png"
    )
}

extension BoxDesignResponse {
    static let mock: Self = (1...6).map {
        .init(
            id: $0,
            sequence: $0,
            boxFullUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/box-full/box_\($0).png",
            boxPartUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/box-part/box_part_1.png",
            boxBottomUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/box-bottom/bottom_\($0).png"
        )
    }
}
