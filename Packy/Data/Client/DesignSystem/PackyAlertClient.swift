//
//  PackyAlertClient.swift
//  Packy
//
//  Created Mason Kim on 1/25/24.
//

import Foundation
import Dependencies

// MARK: - Dependency Values

extension DependencyValues {
    var packyAlert: PackyAlertClient {
        get { self[PackyAlertClient.self] }
        set { self[PackyAlertClient.self] = newValue }
    }
}

// MARK: - PackyAlertClient Client

struct PackyAlertClient {
    var show: @Sendable (AlertConfiguration) async -> Void
}

extension PackyAlertClient: DependencyKey {
    static let liveValue: Self = {
        Self(
            show: {
                await PackyAlertManager.shared.show(configuration: $0)
            }
        )
    }()
}
