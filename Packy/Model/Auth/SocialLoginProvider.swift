//
//  SocialLoginProvider.swift
//  Packy
//
//  Created by Mason Kim on 1/15/24.
//

import Foundation
import SwiftUI

enum SocialLoginProvider: String, Codable {
    case kakao
    case apple
}

// MARK: - Presenting

extension SocialLoginProvider {
    var description: String {
        switch self {
        case .apple:    return "Apple"
        case .kakao:    return "카카오"
        }
    }

    var imageResource: ImageResource {
        switch self {
        case .apple:    return .apple
        case .kakao:    return .kakao
        }
    }

    var backgroundColor: Color {
        switch self {
        case .apple:    return .black
        case .kakao:    return .init(hex: 0xFEE500)
        }
    }
}
