//
//  UnsentBoxResponse.swift
//  Packy
//
//  Created by Mason Kim on 2/21/24.
//

import Foundation

typealias UnsentBoxResponse = [UnsentBoxResponseData]

struct UnsentBoxResponseData: Decodable {
    let id: Int
    let name: String
    let receiverName: String
    let createdAt: String
    let smallImgUrl: String
}

extension UnsentBoxResponseData {
    func toDomain() -> UnsentBox {
        .init(
            id: id,
            name: name,
            receiverName: receiverName,
            date: createdAt.date(fromFormat: .serverDateTime),
            imageUrl: smallImgUrl
        )
    }
}
