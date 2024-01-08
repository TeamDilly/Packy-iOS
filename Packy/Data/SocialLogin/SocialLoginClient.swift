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
    var initKakaoSDK: @Sendable () -> Void
    var handleKakaoUrlIfNeeded: @Sendable (URL) -> Void
    var appleLogin: @Sendable () async throws -> SocialLoginInfo
    var kakaoLogin: @Sendable () async throws -> SocialLoginInfo
}

extension SocialLoginClient: DependencyKey {
    static let liveValue: Self = {
        let appleLoginController = AppleLoginController()
        let kakaoLoginController = KakaoLoginController()

        return Self(
            initKakaoSDK: {
                kakaoLoginController.initSDK()
            },
            handleKakaoUrlIfNeeded: {
                kakaoLoginController.handle(url: $0)
            },
            appleLogin: {
                try await appleLoginController.login()
            },
            kakaoLogin: {
                try await kakaoLoginController.login()
            }
        )
    }()

    static let previewValue: Self = {
        Self(
            initKakaoSDK: {},
            handleKakaoUrlIfNeeded: { _ in },
            appleLogin: { .mock },
            kakaoLogin: { .mock }
        )
    }()
}
