//
//  GiftBoxResponse.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
//

import Foundation

/// 보내는데 성공한 선물 박스 정보
struct SentGiftBoxInfo: Decodable, Equatable {
    let id: Int
    let uuid: String
    let kakaoMessageImgUrl: String?
}
