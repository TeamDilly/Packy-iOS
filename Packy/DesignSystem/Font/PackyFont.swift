//
//  PackyFont.swift
//  Packy
//
//  Created by Mason Kim on 1/7/24.
//

import SwiftUI

enum PackyFont {
    case heading1
    case title1, title2, title3
    case body1, body2, body3, body4, body5, body6

    var pretendard: Pretendard {
        switch self {
        case .heading1:
            return .bold

        case .title1, .title2:   
            return .bold
        case .title3:   
            return .regular

        case .body1, .body2:    
            return .bold
        case .body3, .body4, .body5, .body6:    
            return .regular
        }
    }

    var size: CGFloat {
        switch self {
        case .heading1: 
            return 24

        case .title1:   
            return 24
        case .title2, .title3:   
            return 16

        case .body1:   
            return 18
        case .body2, .body3:
            return 16
        case .body4, .body5:
            return 14
        case .body6:
            return 12
        }
    }

    var lineHeight: CGFloat {
        switch self {
        case .heading1, .title1:
            return 34
        case .title2, .title3, .body1:
            return 24
        case .body2, .body3:
            return 26
        case .body4:
            return 22
        case .body5:
            return 26
        case .body6:
            return 20
        }
    }
}
// 
// extension Font {
//     static func packy(_ font: PackyFont, size: CGFloat? = nil) -> Font {
//         return .custom(type.rawValue, size: size ?? <#default value#>)
//     }
// }
