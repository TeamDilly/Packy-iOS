//
//  BottomMenuManager.swift
//  Packy
//
//  Created by Mason Kim on 2/18/24.
//

import SwiftUI

// MARK: - Configuration

struct BottomMenuConfiguration {
    let confirmTitle: String
    var cancelTitle: String = "취소"
    let confirmAction: () async -> Void
}

// MARK: - PackyAlertManager

@MainActor
final class BottomMenuManager: ObservableObject {
    static let shared = BottomMenuManager()
    private init() {}

    @Published private(set) var isPresented: Bool = false
    private(set) var configuration: BottomMenuConfiguration = .init(confirmTitle: "", confirmAction: {})
    private var continuation: CheckedContinuation<Void, Never>?

    func show(configuration: BottomMenuConfiguration) async {
        self.isPresented = true
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
