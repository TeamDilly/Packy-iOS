//
//  GiftBoxesResponse.swift
//  Packy
//
//  Created by Mason Kim on 2/6/24.
//

import Foundation

struct GiftBoxesResponse: Decodable {
    let content: [GiftBoxesResponseContent]
}

struct GiftBoxesResponseContent: Decodable {
    let id: Int
    let sender: String
    let receiver: String
    let name: String
    let giftBoxDate: String
}

