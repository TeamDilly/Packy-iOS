//
//  Analytics.swift
//  Packy
//
//  Created by Mason Kim on 3/31/24.
//

import Foundation
import SwiftUI
import FirebaseAnalytics

enum AnalyticsEventName: String {
    case view
    case click
}

enum AnalyticsParameterKey: String {
    case pageName       = "PageName"
    case componentName  = "ComponentName"
    case contentId      = "ContentId"
    case emptyItems     = "EmptyItems"
}

struct AnalyticsEventInfo {
    let name: AnalyticsEventName
    let screen: AnalyticsScreen
    var parameters: [AnalyticsParameterKey: Any]
}

enum AnalyticsManager {
    static func setUserId(_ userId: String?) {
        Analytics.setUserID(userId)
    }

    func setUserProperty(value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }

    static func logEvent(_ eventInfo: AnalyticsEventInfo) {
        var parameters: [String: Any] = eventInfo.parameters.reduce(into: [:]) { result, pair in
            result[pair.key.rawValue] = pair.value
        }
        parameters[AnalyticsParameterKey.pageName.rawValue] = eventInfo.screen.rawValue

        Analytics.logEvent(eventInfo.name.rawValue, parameters: parameters)
    }
}

// MARK: - Screen Analytics

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
    func analyticsLog(_ screen: AnalyticsScreen, parameters: [String : Any] = [:]) -> some View {
        onAppear {
            var parameters = parameters
            parameters["PageName"] = screen.rawValue

            Analytics.logEvent(
                AnalyticsEventName.view.rawValue,
                parameters: parameters
            )
        }
    }
}
