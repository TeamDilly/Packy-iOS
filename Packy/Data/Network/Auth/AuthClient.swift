//
//  AuthClient.swift
//  Packy
//
//  Created Mason Kim on 1/15/24.
//

import Foundation
import Dependencies
import Moya

// MARK: - Dependency Values

extension DependencyValues {
    // 변수명 소문자로 변경 필요
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

// MARK: - AuthClient Client

struct AuthClient {
    /// 회원가입
    var signUp: @Sendable (_ authorization: String, SignUpRequest) async throws -> AuthResponse
    /// 로그인
    var signIn: @Sendable (SignInRequest) async throws -> AuthResponse
    /// 회원 탈퇴
    var withdraw: @Sendable () async throws -> String
    /// 토큰 재발급
    var reissueToken: @Sendable (TokenRequest) async throws -> AuthResponse
}

extension AuthClient: DependencyKey {
    static let liveValue: Self = {
        let provider = MoyaProvider<AuthEndpoint>()
        return Self(
            signUp: {
                try await provider.request(.signUp(authorization: $0, request: $1))
            },
            signIn: {
                try await provider.request(.signIn(request: $0))
            },
            withdraw: {
                try await provider.requestEmpty(.withdraw)
            },
            reissueToken: {
                try await provider.request(.reissueToken(request: $0))
            }
        )
    }()

    static let previewValue: Self = {
        Self(
            signUp: { _, _ in .mock },
            signIn: { _ in .mock },
            withdraw: { "" },
            reissueToken: { _ in .mock }
        )
    }()
}
