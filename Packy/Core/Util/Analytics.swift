//
//  Analytics.swift
//  Packy
//
//  Created by Mason Kim on 3/31/24.
//

import Foundation
import SwiftUI

enum AnalyticsScreen: String {
    case boxAddInfo     = "box_add_info"
    case boxChoiceBox   = "box_choice_box"
    case boxDetail      = "box_detail"
    case boxShare       = "box_share"
    case boxAddTitle    = "box_add_title"
    case boxOpenError   = "box_open_error"
    case boxDetailOpen  = "box_detail_open"
}

extension View {
    func analyticsScreen(_ screen: AnalyticsScreen) -> some View {
        analyticsScreen(name: screen.rawValue)
    }
}
