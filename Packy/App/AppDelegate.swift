//
//  AppDelegate.swift
//  Packy
//
//  Created by Mason Kim on 3/31/24.
//

import SwiftUI
import Firebase
import BranchSDK

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        Branch.getInstance().checkPasteboardOnInstall()

        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            // TODO: Access and use Branch Deep Link data here (nav to page, display content, etc.)
            print(params as? [String: AnyObject] ?? [:])
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
