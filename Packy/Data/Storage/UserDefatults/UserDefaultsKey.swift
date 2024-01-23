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
        /// 박스 제작 가이드에 진입한 후면, 모션을 보여주지 않기 위한 flag
        case didEnteredBoxGuide
    }

    enum StringKey: String {
        case none
    }
}
