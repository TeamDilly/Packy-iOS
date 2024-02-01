//
//  ReceivedBox.swift
//  Packy
//
//  Created by Mason Kim on 2/1/24.
//

import Foundation

struct ReceivedBox: Decodable, Equatable {
    let boxFullUrl: String
    let boxPartUrl: String
    let boxBottomUrl: String

    enum CodingKeys: String, CodingKey {
        case boxPartUrl = "boxPart"
        case boxBottomUrl = "boxBottom"
        case boxFullUrl = "boxFull"
    }
}

// MARK: - Mock Data

extension ReceivedBox {
    static let mock: Self = .init(
        boxFullUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/box-full/box_1.png",
        boxPartUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/box-part/box_part_1.png",
        boxBottomUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/box-bottom/bottom_1.png"
    )
}
