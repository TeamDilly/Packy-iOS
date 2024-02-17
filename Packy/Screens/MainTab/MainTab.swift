//
//  MainTab.swift
//  Packy
//
//  Created by Mason Kim on 2/17/24.
//

import Foundation
import SwiftUI

enum MainTab: CaseIterable {
    case home
    case myBox
    case archive

    func image(forSelected isSelected: Bool) -> Image {
        switch self {
        case .home:
            Image(isSelected ? .homeFill : .home)
        case .myBox:
            Image(isSelected ? .giftboxFill : .giftbox)
        case .archive:
            Image(isSelected ? .archiveboxFill : .archivebox)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .home:     return .gray100
        case .myBox:    return .white
        case .archive:  return .gray100
        }
    }
}
