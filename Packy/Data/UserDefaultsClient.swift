//
//  UserDefaultsClient.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import Foundation
import Dependencies

// MARK: - Dependency Values

extension DependencyValues {
    var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}

// MARK: - UserDefaultsClient Client

struct UserDefaultsClient {
    var boolForKey: @Sendable (UserDefaultsKey.BoolKey) -> Bool = { _ in false }
    var stringForKey: @Sendable (UserDefaultsKey.StringKey) -> String? = { _ in "" }

    var removeBool: @Sendable (UserDefaultsKey.BoolKey) async -> Void
    var removeString: @Sendable (UserDefaultsKey.StringKey) async -> Void

    var setBool: @Sendable (Bool, UserDefaultsKey.BoolKey) async -> Void
    var setString: @Sendable (String, UserDefaultsKey.StringKey) async -> Void
}

extension UserDefaultsClient: DependencyKey {
    static let liveValue: Self = {
        let defaults = { UserDefaults.standard }

        return Self(
            boolForKey: { defaults().bool(forKey: $0.rawValue) },
            stringForKey: { defaults().string(forKey: $0.rawValue) },

            removeBool: { defaults().removeObject(forKey: $0.rawValue) },
            removeString: { defaults().removeObject(forKey: $0.rawValue) },

            setBool: { defaults().set($0, forKey: $1.rawValue) },
            setString: { defaults().set($0, forKey: $1.rawValue) }
        )
    }()

    static let testValue: Self = {
        Self(
            removeBool: { _ in },
            removeString: { _ in },
            setBool: { _, _ in },
            setString: { _, _ in }
        )
    }()
}
