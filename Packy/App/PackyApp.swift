//
//  PackyApp.swift
//  Packy
//
//  Created by Mason Kim on 1/7/24.
//

import SwiftUI
import ComposableArchitecture
import BranchSDK

@main
struct PackyApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    private var store: StoreOf<RootFeature> { delegate.store }

    @Dependency(\.socialLogin) var socialLogin

    init() {
        socialLogin.initKakaoSDK()
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
                .packyGlobalAlert()
                .globalBottomMenu()
                .globalLoading()
                .globalSnackbar()
                .onOpenURL { url in
                    socialLogin.handleKakaoUrlIfNeeded(url)
                    store.send(.handleScheme(url.queryParameters))

                    Branch.getInstance().handleDeepLink(url)
                }
        }
    }
}
