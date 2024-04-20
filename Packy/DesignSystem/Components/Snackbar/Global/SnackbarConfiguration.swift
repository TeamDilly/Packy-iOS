//
//  SnackbarConfiguration.swift
//  Packy
//
//  Created by Mason Kim on 4/20/24.
//

import SwiftUI

struct SnackbarConfiguration: Equatable {
    var text: String
    var isDismissGestureEnabled: Bool = true
    var showingSeconds: TimeInterval = 3
    var location: SnackbarLocation = .bottom
    var isFromBottom: Bool { location == .bottom }
}

enum SnackbarLocation {
    case top
    case bottom
}
