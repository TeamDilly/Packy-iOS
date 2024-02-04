//
//  BoxSenderInfo.swift
//  Packy
//
//  Created by Mason Kim on 1/20/24.
//

import Foundation

struct BoxSenderInfo: Equatable {
    let receiver: String
    let sender: String
}

extension BoxSenderInfo {
    static let mock: BoxSenderInfo = .init(receiver: "Mason", sender: "Packy")
}
