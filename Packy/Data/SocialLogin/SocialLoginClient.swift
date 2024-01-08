//
//  SocialLoginClient.swift
//  Packy
//
//  Created Mason Kim on 1/8/24.
//

import Foundation
import Dependencies

// MARK: - Dependency Values

extension DependencyValues {
    var socialLogin: SocialLoginClient {
        get { self[SocialLoginClient.self] }
        set { self[SocialLoginClient.self] = newValue }
    }
}

// MARK: - SocialLoginClient Client

struct SocialLoginClient {
    var appleLogin: @Sendable () async throws -> SocialLoginInfo
    var kakaoLogin: @Sendable () async throws -> SocialLoginInfo
}

extension SocialLoginClient: DependencyKey {
    static let liveValue: Self = {
        let appleLoginController = AppleLoginController()

        return Self(
            appleLogin: {
                try await appleLoginController.login()
            },
            kakaoLogin: {
                // TODO: 수정
                try await appleLoginController.login()
            }
        )
    }()

    static let testValue: Self = {
        Self(
            appleLogin: { .mock },
            kakaoLogin: { .mock }
        )
    }()
}
