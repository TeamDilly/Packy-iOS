//
//  ReceivedBox.swift
//  Packy
//
//  Created by Mason Kim on 2/1/24.
//

import Foundation

struct ReceivedBox: Decodable, Equatable {
    /// 박스의 디자인 id
    let designId: Int
    let boxNormalUrl: String
    let boxTopUrl: String

    enum CodingKeys: String, CodingKey {
        case designId = "id"
        case boxNormalUrl = "boxNormal"
        case boxTopUrl = "boxTop"
    }
}

// MARK: - Mock Data

extension ReceivedBox {
    static let mock: Self = .init(
        designId: 0,
        boxNormalUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/Box/Box_1.png",
        boxTopUrl: "https://packy-bucket.s3.ap-northeast-2.amazonaws.com/admin/design/Box_top/Box_top_1.png"
    )
}
