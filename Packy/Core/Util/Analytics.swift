//
//  Analytics.swift
//  Packy
//
//  Created by Mason Kim on 3/31/24.
//

import Foundation
import SwiftUI
import FirebaseAnalytics

enum AnalyticsScreen: String {
    case boxAddInfo     = "box_add_info"
    case boxChoiceBox   = "box_choice_box"
    case boxDetail      = "box_detail"
    case boxShare       = "box_share"
    case boxAddTitle    = "box_add_title"
    case boxOpenError   = "box_open_error"
    case boxDetailOpen  = "box_detail_open"
}

enum AnalyticsEvent: String {
    case boxDetailDoneButton = "box_detail_done_button"
}

extension View {
    func analyticsScreen(_ screen: AnalyticsScreen, extraParameters: [String : Any] = [:]) -> some View {
        analyticsScreen(name: screen.rawValue, extraParameters: extraParameters)
    }
}

enum AnalyticsManager {
    static func setUserId(_ userId: String?) {
        Analytics.setUserID(userId)
    }

    func setUserProperty(value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }

    static func logEvent(name: String, parameters: [String: Any]?) {
        Analytics.logEvent(name, parameters: parameters)
    }
}
