//
//  SettingMenu.swift
//  Packy
//
//  Created by Mason Kim on 2/5/24.
//

import Foundation

typealias SettingMenuResponse = [SettingMenu]

struct SettingMenu: Decodable, Equatable {
    let type: SettingMenuType
    let url: String

    enum CodingKeys: String, CodingKey {
        case type = "tag"
        case url
    }
}

// MARK: - Mock Data

extension [SettingMenu] {
    static let mock: [SettingMenu] = SettingMenuType.allCases.map {
        .init(type: $0, url: "https://www.naver.com/")
    }
}
