//
//  SocialLoginInfo.swift
//  Packy
//
//  Created by Mason Kim on 1/8/24.
//

import Foundation

struct SocialLoginInfo: Equatable {
    let id: String
    let authorization: String
    let name: String?
    let email: String?
    let provider: SocialLoginProvider
}

// MARK: - Mock Data

extension SocialLoginInfo {
    static let mock = SocialLoginInfo(id: "", authorization: "", name: "mason", email: "packy@dilly.com", provider: .apple)
}
