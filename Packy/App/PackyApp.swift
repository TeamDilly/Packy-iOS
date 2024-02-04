//
//  PackyApp.swift
//  Packy
//
//  Created by Mason Kim on 1/7/24.
//

import SwiftUI
import ComposableArchitecture

@main
struct PackyApp: App {
    @Dependency(\.socialLogin) var socialLogin

    init() {
        socialLogin.initKakaoSDK()
    }

    let store = Store(initialState: RootFeature.State()) { RootFeature() }

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
                .packyGlobalAlert()
                .onOpenURL { url in
                    socialLogin.handleKakaoUrlIfNeeded(url)

                    // TODO: DeepLink Scheme 처리
                    print(url)
                    print(url.scheme)
                    print(url.pathComponents)
                    print(url.path())
                }
        }
    }
}
