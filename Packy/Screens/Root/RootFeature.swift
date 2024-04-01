//
//  RootFeature.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct RootFeature: Reducer {

    @ObservableState
    enum State: Equatable {
        case intro(IntroFeature.State = .init())
        case mainTab(MainTabFeature.State = .init())

        init() { self = .intro() }
    }

    enum Action {
        // MARK: User Action

        // MARK: Inner Business Action
        case _onAppear
        case _changeScreen(State)
        case _handleScheme(QueryParameters)

        // MARK: Inner SetState Action

        // MARK: Child Action
        case intro(IntroFeature.Action)
        case mainTab(MainTabFeature.Action)
    }

    @Dependency(\.socialLogin) var socialLogin
    @Dependency(\.authClient) var authClient
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.keychain) var keychain
    @Dependency(\.packyAlert) var packyAlert
    @Dependency(\.openURL) var openURL

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onAppear:
                socialLogin.initKakaoSDK()

                return .run { send in
                    do {
                        let appStatus = try await authClient.checkStatus()

                        guard appStatus.isAvailable else {
                            await handleInvalidAppStatus(reason: appStatus.reason, send: send)
                            return
                        }
                    } catch {
                        await send(.intro(._moveToLoginOrOnboarding))
                        return
                    }

                    /// AccessToken 존재 시, mainTab 으로 이동
                    if keychain.read(.accessToken) != nil {
                        await send(._changeScreen(.mainTab()), animation: .spring)
                    } else {
                        await send(.intro(._moveToLoginOrOnboarding))
                    }

                    setAnalyticsUserId()

                    await userDefaults.setBool(true, .isPopGestureEnabled)
                }

            case let ._changeScreen(newState):
                state = newState
                return .none

            case let ._handleScheme(queryParameters):
                guard let boxIdString = queryParameters["boxId"],
                      let boxId = Int(boxIdString),
                      keychain.read(.accessToken) != nil else {
                    return .none
                }

                return .run { send in
                    await send(._changeScreen(.mainTab(.init(path: .init([.boxOpen(BoxOpenFeature.State(boxId: boxId))])))))
                }

            case let .intro(action):
                switch action {
                    // 로그인 완료, 회원가입 완료 시 홈으로 이동
                case .login(.delegate(.completeLogin)),
                     .signUp(.delegate(.completeSignUp)):
                    return .send(._changeScreen(.mainTab()), animation: .spring)

                default:
                    return .none
                }

            // 회원탈퇴, 로그아웃 완료 시 로그인 화면으로 이동
            case .mainTab(.path(.element(id: _, action: .deleteAccount(.delegate(.completedSignOut))))),
                 .mainTab(.path(.element(id: _, action: .setting(.delegate(.completeSignOut))))):
                return .send(._changeScreen(.intro(.login())), animation: .spring)

            default:
                return .none
            }
        }
        .ifCaseLet(\.intro, action: \.intro) { IntroFeature() }
        .ifCaseLet(\.mainTab, action: \.mainTab) { MainTabFeature() }
    }
}

// MARK: - Inner Functions

private extension RootFeature {
    func handleInvalidAppStatus(reason: AppStatusInvalidReason?, send: Send<Action>) async -> Void {
        switch reason {
        case .needUpdate:
            await packyAlert.show(
                .init(
                    title: "패키 업데이트 안내",
                    description: "더 나은 서비스 이용을 위해\n최신 버전으로 업데이트해주세요",
                    confirm: "업데이트 하기",
                    isDismissible: false,
                    confirmAction: {
                        await openURL(Constants.appStoreUrl)
                    }
                )
            )

        case .invalidStatus:
            keychain.delete(.accessToken)
            keychain.delete(.refreshToken)
            await send(.intro(._moveToLoginOrOnboarding))

        default:
            break
        }
    }

    func setAnalyticsUserId() {
        let memberId = keychain.read(.memberId)
        AnalyticsManager.setUserId(memberId)
    }
}
