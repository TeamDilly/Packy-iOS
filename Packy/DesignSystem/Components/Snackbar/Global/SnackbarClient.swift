//
//  SnackbarClient.swift
//  Packy
//
//  Created by Mason Kim on 4/20/24.
//

import Foundation
import Dependencies

// MARK: - Dependency Values

extension DependencyValues {
    var snackbar: SnackbarClient {
        get { self[SnackbarClient.self] }
        set { self[SnackbarClient.self] = newValue }
    }
}

// MARK: - SnackbarClient Client

struct SnackbarClient {
    var show: @Sendable (SnackbarConfiguration) -> Void
    var hide: @Sendable () -> Void
}

extension SnackbarClient: DependencyKey {
    static let liveValue: Self = {
        Self(
            show: {
                SnackbarManager.shared.show(configuration: $0)
            },
            hide: {
                SnackbarManager.shared.dismiss()
            }
        )
    }()
}
