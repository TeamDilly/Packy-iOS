//
//  BoxSenderInfo.swift
//  Packy
//
//  Created by Mason Kim on 1/20/24.
//

import Foundation

struct BoxSenderInfo: Equatable {
    let to: String
    let from: String
}

extension BoxSenderInfo {
    static let mock: BoxSenderInfo = .init(to: "Mason", from: "Packy")
}
