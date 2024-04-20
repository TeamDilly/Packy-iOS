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

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Dependency(\.socialLogin) var socialLogin

    init() {
        socialLogin.initKakaoSDK()
    }

    let store = Store(initialState: RootFeature.State()) { RootFeature() }

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
                .packyGlobalAlert()
                .globalBottomMenu()
                .globalLoading()
                .globalSnackbar()
                .onOpenURL { url in
                    socialLogin.handleKakaoUrlIfNeeded(url)
                    store.send(._handleScheme(url.queryParameters))
                }
        }
    }
}
