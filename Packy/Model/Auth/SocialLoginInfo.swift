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
    var identityToken: String?
    var name: String?
    var email: String?
    let provider: SocialLoginProvider
}

// MARK: - Mock Data

extension SocialLoginInfo {
    static let mock = SocialLoginInfo(id: "", authorization: "", identityToken: "", name: "mason", email: "packy@dilly.com", provider: .apple)
}
