//
//  SocialLoginInfo.swift
//  Packy
//
//  Created by Mason Kim on 1/8/24.
//

import Foundation

struct SocialLoginInfo {
    let id: String
    let token: String
    let name: String?
    let email: String?
    let loginType: SocialLoginType
}

enum SocialLoginType {
    case apple
    case kakao
}

// MARK: - Mock Data

extension SocialLoginInfo {
    static let mock = SocialLoginInfo(id: "", token: "", name: "mason", email: "packy@dilly.com", loginType: .apple)
}
