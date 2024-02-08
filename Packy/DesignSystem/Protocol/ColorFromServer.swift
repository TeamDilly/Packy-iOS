//
//  ColorFromServer.swift
//  Packy
//
//  Created by Mason Kim on 2/8/24.
//

import SwiftUI

protocol ColorFromServer {
    var colorHexCode: String { get }
    var opacity: Double { get }
}

extension ColorFromServer {
    var color: Color {
        Color(hexString: colorHexCode, opacity: opacity)
    }
}
