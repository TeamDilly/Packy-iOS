//
//  PopGestureDisableModifier.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import SwiftUI
import Dependencies

extension View {
    func popGestureDisabled() -> some View {
        modifier(PopGestureDisabledViewModifier())
    }
}

struct PopGestureDisabledViewModifier: ViewModifier {
    @Dependency(\.userDefaults) var userDefaults

    func body(content: Content) -> some View {
        content
            .task {
                await userDefaults.setBool(false, .isPopGestureEnabled)
            }
            .onDisappear {
                Task {
                    await userDefaults.setBool(true, .isPopGestureEnabled)
                }
            }
    }
}
