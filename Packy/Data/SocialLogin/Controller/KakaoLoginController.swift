//
//  KakaoLoginController.swift
//  Packy
//
//  Created by Mason Kim on 1/8/24.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

enum KakaoLoginError: Error {
    case invalidToken
    case invalidUser
}

struct KakaoLoginController {
    func initSDK() {
        KakaoSDK.initSDK(appKey: APIKey.kakao)
    }

    func handle(url: URL) {
        guard AuthApi.isKakaoTalkLoginUrl(url) else { return }
        _ = AuthController.handleOpenUrl(url: url)
    }

    @MainActor
    func login() async throws -> SocialLoginInfo {
        return try await withCheckedThrowingContinuation { continuation in
            if UserApi.isKakaoTalkLoginAvailable() {
                loginWithKakaoTalk(continuation)
            } else {
                loginWithKakaoAccount(continuation)
            }
        }
    }

    private func loginWithKakaoTalk(_ continuation: CheckedContinuation<SocialLoginInfo, Error>) {
        UserApi.shared.loginWithKakaoTalk { oauthToken, error in
            if let error {
                continuation.resume(throwing: error)
                return
            }
            guard let oauthToken else {
                continuation.resume(throwing: KakaoLoginError.invalidToken)
                return
            }

            fetchUserInfo(continuation, accessToken: oauthToken.accessToken)
        }
    }

    private func loginWithKakaoAccount(_ continuation: CheckedContinuation<SocialLoginInfo, Error>) {
        UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
            if let error {
                continuation.resume(throwing: error)
                return
            }
            guard let oauthToken else {
                continuation.resume(throwing: KakaoLoginError.invalidToken)
                return
            }

            fetchUserInfo(continuation, accessToken: oauthToken.accessToken)
        }
    }

    private func fetchUserInfo(_ continuation: CheckedContinuation<SocialLoginInfo, Error>, accessToken: String) {
        // TODO: 차후 서버 스펙에 따라 변경 필요
        UserApi.shared.me { user, error in
            if let error {
                continuation.resume(throwing: error)
                return
            }

            guard let user,
                  let userId = user.id else {
                continuation.resume(throwing: KakaoLoginError.invalidUser)
                return
            }

            let info = SocialLoginInfo(
                id: String(userId),
                token: accessToken,
                name: user.kakaoAccount?.name,
                email: user.kakaoAccount?.email,
                loginType: .kakao
            )

            continuation.resume(returning: info)
        }
    }
}
