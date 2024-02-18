//
//  ArchiveTab.swift
//  Packy
//
//  Created by Mason Kim on 2/18/24.
//

import Foundation

enum ArchiveTab: CaseIterable {
    case photo
    case letter
    case music
    case gift

    var description: String {
        switch self {
        case .photo:    return "사진"
        case .letter:   return "편지"
        case .music:    return "음악"
        case .gift:     return "선물"
        }
    }
}
