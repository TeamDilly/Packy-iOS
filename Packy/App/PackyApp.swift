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
    let bStore = Store(initialState: BoxAddTitleAndShareFeature.State(giftBox: .mock, boxDesign: .mock)) { BoxAddTitleAndShareFeature() }

    var body: some Scene {
        WindowGroup {
            // BoxAddTitleAndShareView(store: bStore)
            RootView(store: store)
                .packyGlobalAlert()
                .onOpenURL { url in
                    socialLogin.handleKakaoUrlIfNeeded(url)
                    store.send(._handleScheme(url.queryParameters))
                }
        }
    }
}
