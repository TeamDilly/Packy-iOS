//
//  SettingMenu.swift
//  Packy
//
//  Created by Mason Kim on 2/5/24.
//

import Foundation

typealias SettingMenuResponse = [SettingMenu]

struct SettingMenu: Decodable, Equatable {
    let name: String
    let url: String
}

// MARK: - Mock Data

extension [SettingMenu] {
    static let mock: [SettingMenu] = (0...10).map {
        .init(name: "Menu \($0)", url: "https://www.naver.com/")
    }
}
