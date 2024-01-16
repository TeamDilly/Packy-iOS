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
    }

    enum Action {
        // MARK: User Action
        case kakaoLoginButtonTapped
        case appleLoginButtonTapped

        // MARK: Inner Business Action
        case _onAppear

        // MARK: Delegate Action
        enum Delegate {
            case completeLogin
            case moveToSignUp
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
            let response = try await authClient.signIn(.init(provider: info.provider, authorization: info.token))

            guard response.status == .registered,
                  let tokenInfo = response.tokenInfo else {
                await send(.delegate(.moveToSignUp), animation: .spring)
                return
            }

            keychain.save(.accessToken, tokenInfo.accessToken)
            keychain.save(.refreshToken, tokenInfo.refreshToken)

            await send(.delegate(.completeLogin), animation: .spring)
        } catch let error as ErrorResponse {
            print("error response: \(error.message)")
        } catch {
            print("error: \(error)")
        }
    }
}
