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
    let boxNormalUrl: String
    let boxSmallUrl: String
    let boxSetUrl: String
    let boxTopUrl: String

    enum CodingKeys: String, CodingKey {
        case id, sequence
        case boxNormalUrl = "boxNormal"
        case boxSmallUrl = "boxSmall"
        case boxSetUrl = "boxSet"
        case boxTopUrl = "boxTop"
    }
}

// MARK: - Mock

extension BoxDesign {
    static let mock: Self = .init(
        id: 0,
        sequence: 0,
        boxNormalUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/Box/Box_1.png",
        boxSmallUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/Box_s/Box_s_1.png",
        boxSetUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/Box_set/Box_set_1.png",
        boxTopUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/Box_top/Box_top_1.png"
    )
}

extension BoxDesignResponse {
    static let mock: Self = (1...6).map {
        .init(
            id: $0,
            sequence: $0,
            boxNormalUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/Box_set/Box_set_\($0).png",
            boxSmallUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/Box_s/Box_s_\($0).png",
            boxSetUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/Box/Box_\($0).png",
            boxTopUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/Box_top/Box_top_\($0).png"
        )
    }
}
