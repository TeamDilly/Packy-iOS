//
//  GiftBoxType.swift
//  Packy
//
//  Created by Mason Kim on 2/6/24.
//

import Foundation

/// 선물박스 상태 타입
enum GiftBoxType: Equatable, Encodable {
    /// 보낸 박스
    case sent
    /// 받은 박스
    case received
    /// 주고받은 모든 박스
    case all
}
