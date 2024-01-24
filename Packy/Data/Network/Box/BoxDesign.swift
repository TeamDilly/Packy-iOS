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
    let boxTopUrl: String
    let boxBottomUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case boxTopUrl = "boxTop"
        case boxBottomUrl = "boxBottom"
    }
}

// MARK: - Mock

extension BoxDesign {
    static let mock: Self = .init(id: 0, boxTopUrl: "https://picsum.photos/200", boxBottomUrl: "https://picsum.photos/300")
}

extension BoxDesignResponse {
    static let mock: Self = [
        .init(id: 0, boxTopUrl: "https://picsum.photos/200", boxBottomUrl: "https://picsum.photos/300"),
        .init(id: 1, boxTopUrl: "https://picsum.photos/200", boxBottomUrl: "https://picsum.photos/300"),
        .init(id: 2, boxTopUrl: "https://picsum.photos/200", boxBottomUrl: "https://picsum.photos/300"),
        .init(id: 3, boxTopUrl: "https://picsum.photos/200", boxBottomUrl: "https://picsum.photos/300")
    ]
}
