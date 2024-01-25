//
//  PackyAlertManager.swift
//  Packy
//
//  Created by Mason Kim on 1/26/24.
//

import SwiftUI

// MARK: - Configuration

struct AlertConfiguration {
    var title: String = ""
    var description: String? = nil
    var cancel: String? = nil
    var confirm: String = ""
    var cancelAction: (() async -> Void)? = nil
    var confirmAction: (() async -> Void) = {}

    init(title: String, description: String? = nil, cancel: String? = nil, confirm: String, cancelAction: (() async -> Void)? = nil, confirmAction: @escaping () async -> Void) {
        self.title = title
        self.description = description
        self.cancel = cancel
        self.confirm = confirm
        self.cancelAction = cancelAction
        self.confirmAction = confirmAction
    }
}

// MARK: - PackyAlertManager

@MainActor
final class PackyAlertManager: ObservableObject {
    static let shared = PackyAlertManager()
    private init() {}

    @Published private(set) var isPresented: Bool = false
    private(set) var configuration: AlertConfiguration = .init(title: "", confirm: "", confirmAction: {})
    private var continuation: CheckedContinuation<Void, Never>?

    func show(configuration: AlertConfiguration) async {
        isPresented = true
        self.configuration = configuration
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    func dismiss() {
        isPresented = false
        continuation?.resume()
        continuation = nil
    }
}
