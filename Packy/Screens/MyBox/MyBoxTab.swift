//
//  MyBoxTab.swift
//  Packy
//
//  Created by Mason Kim on 2/4/24.
//

import Foundation

enum MyBoxTab: CaseIterable, CustomStringConvertible {
    case sentBox
    case receivedBox

    var description: String {
        switch self {
        case .sentBox:      "보낸 선물박스"
        case .receivedBox:  "받은 선물박스"
        }
    }
}
