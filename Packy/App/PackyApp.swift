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

    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(initialState: RootFeature.State()) {
                    RootFeature()
                }
            )
            .onOpenURL { url in
                socialLogin.handleKakaoUrlIfNeeded(url)
            }
        }
    }
}
