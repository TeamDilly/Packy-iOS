//
//  LoginFeature.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct LoginFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        var socialLoginInfo: SocialLoginInfo?
    }

    enum Action {
        // MARK: User Action
        case kakaoLoginButtonTapped
        case appleLoginButtonTapped

        // MARK: Inner SetState Action
        case _setSocialLoginInfo(SocialLoginInfo)

        // MARK: Delegate Action
        enum Delegate {
            case completeLogin
            case moveToSignUp(SocialLoginInfo)
        }
        case delegate(Delegate)
    }

    @Dependency(\.socialLogin) var socialLogin
    @Dependency(\.authClient) var authClient
    @Dependency(\.keychain) var keychain

    enum ThrottleId {
        case loginButton
    }

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .kakaoLoginButtonTapped:
                return .run { send in
                    let info = try await socialLogin.kakaoLogin()
                    try await handleSocialLogin(info, send: send)
                }
                .throttle(id: ThrottleId.loginButton, for: .seconds(1), scheduler: DispatchQueue.main, latest: false)

            case .appleLoginButtonTapped:
                return .run { send in
                    let info = try await socialLogin.appleLogin()
                    try await handleSocialLogin(info, send: send)
                }
                .throttle(id: ThrottleId.loginButton, for: .seconds(1), scheduler: DispatchQueue.main, latest: false)

            case let ._setSocialLoginInfo(info):
                state.socialLoginInfo = info
                return .none

            default:
                return .none
            }
        }
    }
}

// MARK: - Inner Functions

private extension LoginFeature {
    func handleSocialLogin(_ info: SocialLoginInfo, send: Send<LoginFeature.Action>) async throws {
        do {
            await send(._setSocialLoginInfo(info))

            let response: SignInResponse
            switch info.provider {
            case .kakao:
                response = try await authClient.signIn(.init(provider: info.provider, authorization: info.authorization))
            case .apple:
                // 애플은 로그인 시 identityToken
                response = try await authClient.signIn(.init(provider: info.provider, authorization: info.identityToken ?? ""))
            }

            guard response.status == .registered,
                  let tokenInfo = response.tokenInfo,
                  let accessToken = tokenInfo.accessToken,
                  let refreshToken = tokenInfo.refreshToken else {
                await send(.delegate(.moveToSignUp(info)), animation: .spring)
                return
            }

            keychain.save(.accessToken, accessToken)
            keychain.save(.refreshToken, refreshToken)

            await send(.delegate(.completeLogin), animation: .spring)
        } catch let error as ErrorResponse {
            print("error response: \(error.message)")
        } catch {
            print("error: \(error)")
        }
    }
}
