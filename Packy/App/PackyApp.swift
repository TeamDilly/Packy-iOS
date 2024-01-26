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

    let boxStore = Store(initialState: BoxStartGuideFeature.State(senderInfo: .mock, boxDesigns: .mock, selectedBox: .mock)) {
        BoxStartGuideFeature()
    }
    var body: some Scene {
        WindowGroup {
            BoxStartGuideView(store: boxStore)
            // RootView(store: store)
                .packyGlobalAlert()
                .onOpenURL { url in
                    socialLogin.handleKakaoUrlIfNeeded(url)
                }
        }
    }
}
