//
//  Profile.swift
//  Packy
//
//  Created by Mason Kim on 2/6/24.
//

import Foundation

/// 유저 프로필 정보
struct Profile: Equatable, Decodable {
    let id: Int
    let provider: SocialLoginProvider
    let nickname: String
    let imageUrl: String
}

// MARK: - Mock Data

extension Profile {
    static let mock = Profile(
        id: 0,
        provider: .apple,
        nickname: "mason",
        imageUrl: Constants.mockImageUrl
    )
}
