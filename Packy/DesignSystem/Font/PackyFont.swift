//
//  PackyFont.swift
//  Packy
//
//  Created by Mason Kim on 1/7/24.
//

import SwiftUI

enum PackyFont {
    case heading1, heading2, heading3
    case body1, body2, body3, body4, body5, body6

    var pretendard: Pretendard {
        switch self {
        case .heading1, .heading2, .body1:
            return .bold
        case .heading3:
            return .medium
        case .body3:
            return .semibold
        case .body2, .body4, .body5, .body6:
            return .regular
        }
    }

    var size: CGFloat {
        switch self {
        case .heading1: 
            return 24
        case .heading2:
            return 18
        case .heading3:
            return 18
        case .body1, .body2:
            return 16
        case .body3, .body4, .body5:
            return 14
        case .body6:
            return 12
        }
    }

    var lineHeight: CGFloat {
        switch self {
        case .heading1:
            return 34
        case .heading2:
            return 24
        case .heading3:
            return 27
        case .body1, .body2:
            return 26
        case .body3, .body4:
            return 22
        case .body5:
            return 26
        case .body6:
            return 20
        }
    }
}
