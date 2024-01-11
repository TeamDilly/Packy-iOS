//
//  UserNotificationClient.swift
//  Packy
//
//  Created Mason Kim on 1/11/24.
//

import Foundation
import Dependencies
import UserNotifications

// MARK: - Dependency Values

extension DependencyValues {
    var userNotification: UserNotificationClient {
        get { self[UserNotificationClient.self] }
        set { self[UserNotificationClient.self] = newValue }
    }
}

// MARK: - UserNotificationClient Client

struct UserNotificationClient {
    /// 알림 권한 요청
    var requestAuthorization: @Sendable (UNAuthorizationOptions) async throws -> Bool
}

extension UserNotificationClient: DependencyKey {
    static let liveValue = Self(
        requestAuthorization: {
            try await UNUserNotificationCenter.current().requestAuthorization(options: $0)
        }
    )

    static let previewValue = Self(
        requestAuthorization: { _ in true }
    )
}
