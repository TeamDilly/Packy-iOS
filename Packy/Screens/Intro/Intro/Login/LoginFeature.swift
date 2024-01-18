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

    struct State: Equatable {
        var socialLoginInfo: SocialLoginInfo?
    }

    enum Action {
        // MARK: User Action
        case kakaoLoginButtonTapped
        case appleLoginButtonTapped

        // MARK: Inner Business Action
        case _onAppear

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

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .kakaoLoginButtonTapped:
                return .run { send in
                    let info = try await socialLogin.kakaoLogin()
                    try await handleSocialLogin(info, send: send)
                }

            case .appleLoginButtonTapped:
                return .run { send in
                    let info = try await socialLogin.appleLogin()
                    try await handleSocialLogin(info, send: send)
                }

            case let ._setSocialLoginInfo(info):
                state.socialLoginInfo = info
                return .none

            case ._onAppear:
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

            let response = try await authClient.signIn(.init(provider: info.provider, authorization: info.token))

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
