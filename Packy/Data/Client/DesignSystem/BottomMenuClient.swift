//
//  BottomMenuClient.swift
//  Packy
//
//  Created by Mason Kim on 2/18/24.
//

import Foundation
import Dependencies

// MARK: - Dependency Values

extension DependencyValues {
    var bottomMenu: BottomMenuClient {
        get { self[BottomMenuClient.self] }
        set { self[BottomMenuClient.self] = newValue }
    }
}

// MARK: - BottomMenu Client

struct BottomMenuClient {
    var show: @Sendable (BottomMenuConfiguration) async -> Void
}

extension BottomMenuClient: DependencyKey {
    static let liveValue: Self = {
        Self(
            show: {
                await BottomMenuManager.shared.show(configuration: $0)
            }
        )
    }()
}
