//
//  AppDelegate.swift
//  Packy
//
//  Created by Mason Kim on 3/31/24.
//

import SwiftUI
import Firebase
import BranchSDK
import ComposableArchitecture

typealias DeepLinkParameters = [String: AnyObject]

final class AppDelegate: NSObject, UIApplicationDelegate {
    let store = Store(initialState: RootFeature.State()) { RootFeature() }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        #if DEBUG
        Branch.setUseTestBranchKey(true)
        Branch.enableLogging()
        #endif

        let branch = Branch.getInstance()
        branch.checkPasteboardOnInstall()
        branch.initSession(launchOptions: launchOptions) { (params, error) in
            guard let params = params as? [String: AnyObject] else { return }
            self.store.send(.handleDeepLink(params))
        }

        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        Branch.getInstance().application(app, open: url, options: options)
        return true
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        Branch.getInstance().continue(userActivity)
        return true
    }
}
