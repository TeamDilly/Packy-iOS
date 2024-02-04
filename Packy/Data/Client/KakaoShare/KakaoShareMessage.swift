//
//  KakaoShareMessage.swift
//  Packy
//
//  Created by Mason Kim on 2/2/24.
//

import Foundation

struct KakaoShareMessage: Encodable {
    let sender: String
    let receiver: String
    let imageUrl: String
    let boxId: String

    enum CodingKeys: String, CodingKey {
        case sender
        case receiver
        case imageUrl = "image_url"
        case boxId
    }
}
