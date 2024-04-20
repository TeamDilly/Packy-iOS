//
//  SnackbarManager.swift
//  Packy
//
//  Created by Mason Kim on 4/20/24.
//

import SwiftUI

final class SnackbarManager: ObservableObject {
    static let shared = SnackbarManager()
    private init() {}

    @Published private(set) var isPresented: Bool = false
    private(set) var configuration: SnackbarConfiguration = .init(text: "")

    private var showTask: Task<Void, Never>?

    func show(configuration: SnackbarConfiguration) {
        showTask?.cancel()
        showTask = Task {
            await MainActor.run {
                self.isPresented = false
                self.configuration = configuration
                self.isPresented = true
            }

            try? await Task.sleep(for: .seconds(configuration.showingSeconds))
            await MainActor.run {
                dismiss()
            }
        }
    }

    func dismiss() {
        isPresented = false
    }
}
