//
//  PersistentKey+UserDefaultsKey.swift
//  Packy
//
//  Created by Mason Kim on 8/20/24.
//

import Foundation
import ComposableArchitecture

/// `UserDefaults` 전략을 사용하는 ``AppStorageKey`` Shared State 를 위한 Key
extension PersistenceKey {
    static func appStorage(_ key: UserDefaultsKey.BoolKey) -> Self where Self == PersistenceKeyDefault<AppStorageKey<Bool>> {
        PersistenceKeyDefault(.appStorage(key.rawValue), false)
    }

    static func appStorage(_ key: UserDefaultsKey.StringKey) -> Self where Self == AppStorageKey<String?> {
        appStorage(key.rawValue)
    }

    static func appStorage(_ key: UserDefaultsKey.DataKey) -> Self where Self == AppStorageKey<Data?> {
        appStorage(key.rawValue)
    }

    static func appStorage(_ key: UserDefaultsKey.IntegerKey) -> Self where Self == PersistenceKeyDefault<AppStorageKey<Int>> {
        PersistenceKeyDefault(.appStorage(key.rawValue), 0)
    }

    static func appStorage(_ key: UserDefaultsKey.DoubleKey) -> Self where Self == PersistenceKeyDefault<AppStorageKey<Double>> {
        PersistenceKeyDefault(.appStorage(key.rawValue), 0)
    }
}
