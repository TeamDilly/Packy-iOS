//
//  Gift.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
//

import Foundation

struct Gift: Codable, Equatable, Hashable {
    let type: String
    var url: String
}

/// 서버에 이미지를 업로드하기 전의 data
struct GiftRawData: Equatable {
    let type: String
    let data: Data
}

// MARK: - Mock Data

extension Gift {
    static var mock: Self {
        return Gift(
            type: "photo",
            url: Constants.mockImageUrl
        )
    }
}

extension GiftRawData {
    static var mock: Self {
        return .init(
            type: "photo",
            data: Data()
        )
    }
}
