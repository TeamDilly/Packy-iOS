//
//  UserDefaultsKey.swift
//  Packy
//
//  Created by Mason Kim on 1/7/24.
//

import Foundation

/// UserDefaults Client 에서 저장하기 위한 Key
enum UserDefaultsKey {
    enum BoolKey: String {
        case hasOnboarded
        case isPopGestureEnabled
    }

    enum StringKey: String {
        case none
    }
}
