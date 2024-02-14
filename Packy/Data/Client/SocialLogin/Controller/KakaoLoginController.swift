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

final class KakaoLoginController {
    private var continuation: CheckedContinuation<SocialLoginInfo, Error>? = nil

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
            self.continuation = continuation

            if UserApi.isKakaoTalkLoginAvailable() {
                loginWithKakaoTalk()
            } else {
                loginWithKakaoAccount()
            }
        }
    }

    private func loginWithKakaoTalk() {
        UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
            guard let self else { return }

            if let error {
                continuation?.resume(throwing: error)
                continuation = nil
                return
            }
            guard let oauthToken else {
                continuation?.resume(throwing: KakaoLoginError.invalidToken)
                continuation = nil
                return
            }

            fetchUserInfo(accessToken: oauthToken.accessToken)
        }
    }

    private func loginWithKakaoAccount() {
        UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
            guard let self else { return }

            if let error {
                continuation?.resume(throwing: error)
                continuation = nil
                return
            }
            guard let oauthToken else {
                continuation?.resume(throwing: KakaoLoginError.invalidToken)
                continuation = nil
                return
            }

            fetchUserInfo(accessToken: oauthToken.accessToken)
        }
    }

    private func fetchUserInfo(accessToken: String) {
        UserApi.shared.me { [weak self] user, error in
            guard let self else { return }
            defer { continuation = nil }

            if let error {
                continuation?.resume(throwing: error)
                return
            }

            guard let user,
                  let userId = user.id else {
                continuation?.resume(throwing: KakaoLoginError.invalidUser)
                return
            }

            let info = SocialLoginInfo(
                id: String(userId),
                authorization: accessToken,
                name: user.kakaoAccount?.profile?.nickname,
                email: user.kakaoAccount?.email,
                provider: .kakao
            )

            continuation?.resume(returning: info)
            continuation = nil
        }
    }
}
