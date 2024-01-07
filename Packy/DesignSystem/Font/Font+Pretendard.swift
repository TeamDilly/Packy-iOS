//
//  Font+Pretendard.swift
//  Packy
//
//  Created by Mason Kim on 1/7/24.
//

import SwiftUI

extension Font {
    static func pretendard(_ type: Pretendard, size: CGFloat) -> Font {
        return .custom(type.rawValue, size: size)
    }
}
