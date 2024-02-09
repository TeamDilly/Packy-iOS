//
//  GiftBoxesRequest.swift
//  Packy
//
//  Created by Mason Kim on 2/6/24.
//

import Foundation

struct GiftBoxesRequest: Encodable {
    var lastGiftBoxDate: String = Date().formattedString(by: .serverDateTime)
    var type: GiftBoxType = .all
    var size: Int = 6
}
